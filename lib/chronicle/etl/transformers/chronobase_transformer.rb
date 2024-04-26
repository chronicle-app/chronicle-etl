# frozen_string_literal: true

module Chronicle
  module ETL
    class ChronobaseTransformer < Chronicle::ETL::Transformer
      PROPERTY_MAP = {
        source: :provider,
        source_id: :provider_id,
        url: :provider_url,
        end_time: :end_at,
        start_time: :start_at,

        name: :title,
        description: :body,
        text: :body,

        recipient: :consumers,
        agent: :actor,
        object: :involved,

        # music ones
        by_artist: :creators,
        in_album: :containers
      }.freeze

      VERB_MAP = {
        ListenAction: 'listened',
        CommunicateAction: 'messaged'
      }.freeze

      ENTITY_MAP = {
        MusicRecording: 'song',
        MusicAlbum: 'album',
        MusicGroup: 'musicartist',
        Message: 'message',
        Person: 'person'
      }.freeze

      register_connector do |r|
        r.identifier = :chronobase
        r.description = 'records to chronobase schema'
      end

      def transform(record)
        deeply_convert_record(record.data)
      end

      private

      def deeply_convert_record(record)
        type = activity?(record) ? 'activity' : 'entity'

        properties = record.properties.compact.each_with_object({}) do |(k, v), h|
          key = PROPERTY_MAP[k.to_sym] || k
          h[key] = v
        end

        properties[:verb] = VERB_MAP[record.type_id.to_sym] if VERB_MAP.key?(record.type_id.to_sym)
        properties[:represents] = ENTITY_MAP[record.type_id.to_sym] if ENTITY_MAP.key?(record.type_id.to_sym)

        properties.transform_values! do |v|
          case v
          when Chronicle::Models::Base
            deeply_convert_record(v)
          when Array
            v.map { |e| e.is_a?(Chronicle::Models::Base) ? deeply_convert_record(e) : e }
          else
            v
          end
        end

        Chronicle::Serialization::Record.new(
          id: record.id,
          type: type,
          properties: properties.compact,
          meta: {
            dedupe_on: transform_dedupe_on(record)
          },
          schema: 'chronobase'
        )
      end

      def activity?(record)
        record.type_id.end_with?('Action')
      end

      def transform_dedupe_on(record)
        property_map_with_type = PROPERTY_MAP.merge({
          type: activity?(record) ? :verb : :represents
        })

        record.dedupe_on.map do |set|
          set.map do |d|
            property_map_with_type[d] || d
          end.join(',')
        end
      end
    end
  end
end
