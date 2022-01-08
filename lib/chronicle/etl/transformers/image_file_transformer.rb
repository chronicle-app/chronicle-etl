require 'marcel'
require 'base64'

module Chronicle
  module ETL
    class ImageFileTransformer < Chronicle::ETL::Transformer
      register_connector do |r|
        r.identifier = 'image-file'
        r.description = 'an image file'
      end

      DEFAULT_OPTIONS = {
        timestamp_strategy: 'file_mtime',
        id_strategy: 'file_hash',
        verb: 'photographed',
        include_image_data: true
      }.freeze

      def initialize(*args)
        super(*args)
        @options = DEFAULT_OPTIONS.deep_merge(@options)
      end

      def transform
        record = build_created(@extraction.data)
      end

      def friendly_identifier
        File.basename(@extraction.data)
      end

      def id
        @id ||= build_id(file: @extraction.data, strategy: @options[:id_strategy])
      end

      def timestamp
        @timestamp ||= build_timestamp(file: @extraction.data, strategy: @options[:timestamp_strategy])
      end

      private

      def build_created(file)
        record = ::Chronicle::ETL::Models::Activity.new
        record.verb = @options[:verb]
        record.provider = @options[:provider]
        record.provider_id = id
        record.end_at = timestamp
        record.dedupe_on = [[:provider_id, :verb, :provider]]

        record.involved = build_image(file)
        record.actor = build_actor
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

      def build_image(file)
        image = ::Chronicle::ETL::Models::Entity.new
        image.represents = @options[:involved][:represents]
        image.title = File.basename(file)
        image.provider = @options[:involved][:provider]
        image.provider_id = id
        image.metadata[:ocr_text] = ocr_image(file: file, strategy: @options[:ocr_strategy])
        image.dedupe_on = [[:provider, :provider_id, :represents]]

        if @options[:include_image_data]
          attachment = ::Chronicle::ETL::Models::Attachment.new
          attachment.data = build_image_data(file)
          image.attachments = [attachment]
        end

        image
      end

      def build_image_data(file)
        mimetype = Marcel::MimeType.for(file)
        "data:#{mimetype};base64,#{Base64.encode64(File.read(file))}"
      end

      def build_id(file:, strategy: [])
        strategy = [strategy].flatten.compact
        strategy.each do |s|
          result = send("build_id_from_#{s}".to_sym, file)
          return result if result
        end
      end

      def build_id_from_file_hash(file)
        Digest::SHA256.hexdigest(File.read(file))
      end

      def build_timestamp(file:, strategy: [])
        strategy = [strategy].flatten.compact
        strategy.each do |strategy|
          result = send("build_timestamp_from_#{strategy}".to_sym, file)
          return result if result
        end
      end

      def build_timestamp_from_file_mtime(file)
        File.mtime(file)
      end

      def ocr_image(file:, strategy: [])
        strategy = [strategy].flatten.compact
        strategy.each do |strategy|
          result = send("ocr_image_with_#{strategy}".to_sym, file)
          return result if result
        end
      end

      def ocr_image_with_macocr(file)
        `macocr "#{file.path}"`
      end
    end
  end
end
