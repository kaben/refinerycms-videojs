require 'dragonfly'

module Refinery
  module Videos
    module Dragonfly

      class << self
        def setup!
          app_videos = ::Dragonfly.app(:refinery_videos)

          app_videos.define_macro(::Refinery::Videos::VideoFile, :video_accessor)

          app_videos.analyser.register(::Dragonfly::Analysis::FileCommandAnalyser)
          app_videos.content_disposition = :attachment
        end

        def configure!
          app_videos = ::Dragonfly.app(:refinery_videos)
          app_videos.configure do
            datastore :file, {
              :root_path => Refinery::Videos.datastore_root_path,
            }
            url_format Refinery::Videos.dragonfly_url_format
            url_host Refinery::Videos.dragonfly_url_host
            secret Refinery::Videos.dragonfly_secret

          end

          if ::Refinery::Videos.s3_backend
            require 'dragonfly/s3_data_store'
            options = {
              bucket_name: Refinery::Videos.s3_bucket_name,
              access_key_id: Refinery::Videos.s3_access_key_id,
              secret_access_key: Refinery::Videos.s3_secret_access_key
            }
            # S3 Region otherwise defaults to 'us-east-1'
            options.update(region: Refinery::Videos.s3_region) if Refinery::Videos.s3_region
            app_videos.use_datastore :s3, options

          end
        end

        def attach!(app)
          if defined?(::Rack::Cache)
            unless app.config.action_controller.perform_caching && app.config.action_dispatch.rack_cache
              app.config.middleware.insert 0, ::Rack::Cache, {
                verbose: true,
                metastore: URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/meta"), # URI encoded in case of spaces
                entitystore: URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/body")
              }
            end
            app.config.middleware.insert_after ::Rack::Cache, ::Dragonfly::Middleware, :refinery_videos
          else
            app.config.middleware.use ::Dragonfly::Middleware, :refinery_videos
          end
        end

       
      end

    end
  end
end
