require 'forwardable'
require 'sequel'
require 'xdg'

module Chronicle
  module ETL
    # Saves JobLogs to db and loads previous ones
    class JobLogger
      extend Forwardable

      def_delegators :@job_log, :start, :finish, :error, :log_transformation, :duration, :success
      attr_accessor :job_log

      # For a given `job_id`, return the last successful log
      def self.load_latest(_job_id)
        with_db_connection do |db|
          attrs = db[:job_logs].reverse_order(:finished_at).where(success: true).first
          JobLog.build_from_serialized(attrs) if attrs
        end
      end

      def self.with_db_connection
        initialize_db unless db_exists?
        Sequel.connect("sqlite://#{db_filename}") do |db|
          initialize_schema(db) unless schema_exists?(db)
          yield db
        end
      end

      def self.db_exists?
        File.exist?(db_filename)
      end

      def self.schema_exists?(db)
        db.tables.include? :job_logs
      end

      def self.db_filename
        base = Pathname.new(XDG::Data.new.home)
        base.join('job_log.db')
      end

      def self.initialize_db
        FileUtils.mkdir_p(File.dirname(db_filename))
      end

      def self.initialize_schema(db)
        db.create_table :job_logs do
          primary_key :id
          String :job_id, null: false
          String :last_id
          Time :highest_timestamp
          Integer :num_records_processed
          boolean :success, default: false
          Time :started_at
          Time :finished_at
        end
      end

      # Create a new JobLogger
      def initialize(job)
        @job_log = JobLog.new do |job_log|
          job_log.job = job
        end
      end

      # Save this JobLogger's JobLog to db
      def save
        return unless @job_log.save_log?

        JobLogger.with_db_connection do |db|
          dataset = db[:job_logs]
          dataset.insert(@job_log.serialize)
        end
      end

      def summarize
        @job_log.inspect
      end
    end
  end
end
