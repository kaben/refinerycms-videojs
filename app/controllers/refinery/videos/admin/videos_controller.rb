module Refinery
  module Videos
    module Admin
      class VideosController < ::Refinery::AdminController

        crudify :'refinery/videos/video',
                :title_attribute => 'title',
                :xhr_paging => true,
                :order => 'position ASC',
                :sortable => true

        before_filter :set_embedded, :only => [:new, :create]

        def show
          @video = Video.find(params[:id])
        end

        def new
          @video = Video.new
          @video.video_files.build
        end

        def update
          puts "Refinery::Videos::Admin::VideoController.update video_params: #{video_params}"
          former_ext_file_ids = @video.video_files.where(use_external: true).pluck(:id)
          if @video.update_attributes(video_params)
            flash.notice = t(
              'refinery.crudify.updated',
              :what => "#{@video.title}"
            )
            create_or_update_successful
            @video.video_files.where('id in (?)', former_ext_file_ids).destroy_all
            puts "Refinery::Videos::Admin::VideoController.update successful."
          else
            create_or_update_unsuccessful 'edit'
            puts "Refinery::Videos::Admin::VideoController.update failed."
          end
        end

        def insert
          if searching?
            search_all_videos 
          else
            find_all_videos
          end
          paginate_videos
        end

        def append_to_wym
          @video = Video.find(params[:video_id])
          params['video'].each do |key, value|
            @video.config[key.to_sym] = value
          end
          @html_for_wym = @video.to_html
        end

        def dialog_preview
          @video = Video.find(params[:id].delete('video_'))
          w, h = @video.config[:width], @video.config[:height]
          @video.config[:width], @video.config[:height] = 300, 200
          @preview_html = @video.to_html
          @video.config[:width], @video.config[:height] = w, h
          @embedded = true if @video.use_shared
        end

        protected

        def video_params
          params.require(:video).permit(:title, :poster_id, {:video_files_attributes => [:use_external, :file, :external_url]}, :external_url, :width, :height, :autoplay, :controls, :preload, :loop, :position, :embed_tag, :use_shared)
        end

        private

        def paginate_videos
          @videos = @videos.paginate(:page => params[:page], :per_page => Video.per_page(true))
        end

        def set_embedded
          @embedded = true if params['embedded']
        end

      end
    end
  end
end
