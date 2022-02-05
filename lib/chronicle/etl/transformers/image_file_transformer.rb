require 'mini_exiftool'
require 'active_support'
require 'active_support/core_ext/object'
require 'active_support/core_ext/time'
require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/string/inflections'

module Chronicle
  module ETL
    # Transform a JPEG or other image file into a record.
    # By default, file mtime and a hash of the file content is used to build
    # the timestamp and ID respectively but other options are available (such
    # as reading EXIF tags or extended attributes from the filesystem).
    #
    # TODO: This should be extracted into its own plugin
    class ImageFileTransformer < Chronicle::ETL::Transformer
      register_connector do |r|
        r.identifier = 'image-file'
        r.description = 'an image file'
      end

      DEFAULT_OPTIONS = {
        timestamp_strategy: 'file_mtime',
        id_strategy: 'file_hash',
        verb: 'photographed',

        # EXIF tags often don't have timezones
        timezone_default: 'Eastern Time (US & Canada)',
        include_image_data: true
      }.freeze

      def initialize(*args)
        super(*args)
        @options = @options.reverse_merge(DEFAULT_OPTIONS)
      end

      def transform
        # FIXME: set @filename; use block for reading file when necessary
        @file = File.open(@extraction.data)
        record = build_created(@file)
        @file.close
        record
      end

      def friendly_identifier
        @file.path
      end

      def id
        @id ||= begin
          id = build_with_strategy(field: :id, strategy: @options[:id_strategy])
          raise UntransformableRecordError.new("Could not build id", transformation: self) unless id

          id
        end
      end

      def timestamp
        @timestamp ||= begin
          ts = build_with_strategy(field: :timestamp, strategy: @options[:timestamp_strategy])
          raise UntransformableRecordError.new("Could not build timestamp", transformation: self) unless ts

          ts
        end
      end

      private

      def build_created(file)
        record = ::Chronicle::ETL::Models::Activity.new
        record.verb = @options[:verb]
        record.provider = @options[:provider]
        record.provider_id = id
        record.end_at = timestamp
        record.dedupe_on = [[:provider_id, :verb, :provider]]

        record.involved = build_image
        record.actor = build_actor

        record.assign_attributes(build_gps)
        record
      end

      def build_actor
        actor = ::Chronicle::ETL::Models::Entity.new
        actor.represents = 'identity'
        actor.provider = @options[:actor][:provider]
        actor.slug = @options[:actor][:slug]
        actor.dedupe_on = [[:provider, :slug, :represents]]
        actor
      end

      def build_image
        image = ::Chronicle::ETL::Models::Entity.new
        image.represents = @options[:involved][:represents]
        image.title = build_title
        image.body = exif['Description']
        image.provider = @options[:involved][:provider]
        image.provider_id = id
        image.assign_attributes(build_gps)
        image.dedupe_on = [[:provider, :provider_id, :represents]]

        if @options[:ocr_strategy]
          ocr_text = build_with_strategy(field: :ocr, strategy: @options[:ocr_strategy])
          image.metadata[:ocr_text] = ocr_text if ocr_text
        end

        names = extract_people_depicted
        tags = extract_keywords(names)

        image.depicts = build_people_depicted(names)
        image.abouts = build_keywords(tags)

        if @options[:include_image_data]
          attachment = ::Chronicle::ETL::Models::Attachment.new
          attachment.data = build_image_data
          image.attachments = [attachment]
        end

        image
      end

      def build_keywords(topics)
        topics.map do |topic|
          t = ::Chronicle::ETL::Models::Entity.new
          t.represents = 'topic'
          t.provider = @options[:involved][:provider]
          t.title = topic
          t.slug = topic.parameterize
          t.dedupe_on = [[:provider, :represents, :slug]]
          t
        end
      end

      def build_people_depicted(names)
        names.map do |name|
          identity = ::Chronicle::ETL::Models::Entity.new
          identity.represents = 'identity'
          identity.provider = @options[:involved][:provider]
          identity.slug = name.parameterize
          identity.title = name
          identity.dedupe_on = [[:provider, :represents, :slug]]
          identity
        end
      end

      def build_gps
        return {} unless exif['GPSLatitude']

        {
          lat: exif['GPSLatitude'],
          lng: exif['GPSLongitude'],
          elevation: exif['GPSAltitude']
        }
      end

      def build_image_data
        ::Chronicle::ETL::Utils::BinaryAttachments.filename_to_base64(filename: @file.path)
      end

      def build_title
        File.basename(@file)
      end

      def build_with_strategy(field:, strategy:[])
        strategies = [strategy].flatten.compact
        strategies.each do |s|
          builder_method = "build_#{field}_using_#{s}"
          result = send(builder_method.to_sym)
          return result if result
        end
        return
      end

      def build_id_using_file_hash
        Digest::SHA256.hexdigest(File.read(@file))
      end

      def build_id_using_xattr_version
        load_value_from_xattr_plist("com.apple.metadata:kMDItemVersion")
      end

      def build_id_using_xmp_document_id
        exif['OriginalDocumentID'] || exif['DerivedFromDocumentID']
      end

      def build_timestamp_using_file_mtime
        File.mtime(@file)
      end

      def build_timestamp_using_exif_datetimeoriginal
        # EXIF tags don't have timezone information. This is a DateTime in UTC
        timestamp = exif['DateTimeOriginal'] || return

        if exif['OffsetTimeOriginal']
          # Offset tags are only available in newer EXIF tags. If it exists, we
          # use it instead of UTC
          timestamp = timestamp.change(offset: exif['OffsetTimeOriginal'])
        elsif false
          # TODO: support option of using GPS coordinates to determine timezone
        else
          zone = ActiveSupport::TimeZone.new(@options[:timezone_default])
          timestamp = zone.parse(timestamp.asctime)
        end

        timestamp
      end

      # TODO: add documentation for how to set up `macocr`
      def build_ocr_using_macocr
        `macocr "#{@file.path}" 2>/dev/null`.presence
      end

      def exif
        @exif ||= MiniExiftool.new(
          @file.path,
          numerical: true,

          # EXIF timestamps don't have timezone information. MiniExifTool uses Time
          # by default which parses timestamps in local time zone. Using DateTime
          # parses dates as UTC and then we can apply a timezone offset if the optional
          # EXIF timezone offset fields are available.
          # https://github.com/janfri/mini_exiftool/issues/39#issuecomment-832587649
          timestamps: DateTime
        )
      end

      # Figure out which faces are tagged as regions and return a list of their names
      def extract_people_depicted
        return [] unless exif['RegionName']

        names = [exif['RegionName']].flatten
        types = [exif['RegionType']].flatten

        names.zip(types).select{|x| x[1] == 'Face'}.map{|x| x[0]}.uniq
      end

      # Extract image keywords from EXIF/IPTC tag and subtract out those of which are
      # tagged people (determiend by looking at face regions)
      def extract_keywords(people_names = [])
        [exif['Keywords'] || []].flatten - people_names
      end

      def load_value_from_xattr_plist attribute
        require 'nokogiri'
        xml = `xattr -p #{attribute} \"#{@file.path}\" | xxd -r -p | plutil -convert xml1 -o - -- - 2>/dev/null`
        return unless xml
        value = Nokogiri::XML.parse(r).xpath("//string").text
        return value.presence
      end
    end
  end
end
