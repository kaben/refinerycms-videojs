require 'dragonfly'

module Refinery
  module Videos
    class Video < Refinery::Core::BaseModel

      self.table_name = 'refinery_videos'
      acts_as_indexed :fields => [:title]

      validates :title, :presence => true
      validate :one_source

      has_many :video_files, :dependent => :destroy
      accepts_nested_attributes_for :video_files

      belongs_to :poster, :class_name => '::Refinery::Image'
      accepts_nested_attributes_for :poster

      ################## Video config options
      serialize :config, Hash
      CONFIG_OPTIONS = {
          :autoplay => "false", :width => "300", :height => "200",
          :controls => "true", :preload => "false", :loop => "false"
      }

      # Create getters and setters
      CONFIG_OPTIONS.keys.each do |option|
        define_method option do
          self.config[option]
        end
        define_method "#{option}=" do |value|
          self.config[option] = value
        end
      end
      #######################################

      ########################### Callbacks
      after_initialize :set_default_config
      #####################################

      def to_html
        if use_shared
          update_from_config
          return wrap_embed_tag_safe
        end

        data_setup = []
        CONFIG_OPTIONS.keys.each do |option|
          if option && (option != :width && option != :height)
            data_setup << "\"#{option}\": #{config[option] || '\"auto\"'}"
          end
        end
        data_setup << "\"poster\": \"#{poster.url}\"" if poster

        poster_url_attribute = "   poster=\"#{poster.url}\"\n" if poster
        poster_url_attribute ||= ""

        sources = []
        last_file = video_files.last
        if last_file.use_external
          # Regular expression to check for YouTube or Vimeo URLs.
          url_re = /^https?:\/\/(\w*\.)?(youtu|vimeo).*/
          external_url = last_file.external_url
          case url_re.match(external_url)[-1]
          when 'youtu'
            data_setup << '"techOrder": ["youtube"]'
          when 'vimeo'
            data_setup << '"techOrder": ["vimeo"]'
          else
            data_setup << '"techOrder": ["html5", "flash"]'
          end
          data_setup << "\"src\": \"#{external_url}\""
        else
          video_files.each do |file|
            if file.use_external
              sources << ["<source src=\"#{file.external_url}\" type=\"#{file.file_mime_type}\"/>"]
            else
              sources << ["<source src=\"#{file.url}\" type=\"#{file.file_mime_type}\"/>"]
            end if file.exist?
          end
        end
        all_sources = "  #{sources.join}\n" if !sources.empty?
        all_sources ||= ""


        html = %Q{
<div class="video_embeded">
 <video id="video_#{self.id}" class="video-js #{Refinery::Videos.skin_css_class}"
   controls="true" preload="auto" width="#{config[:width]}" height="#{config[:height]}"
#{poster_url_attribute}
   data-setup='{#{data_setup.join(', ')}}'
  >
#{all_sources}
 </video>
</div>
}

        html.html_safe
      end

      def wrap_embed_tag_safe
        ('<div class="video_embeded">' + embed_tag + '</div>').html_safe
      end


      def short_info
        return [['.shared_source', embed_tag.scan(/src=".+?"/).first]] if use_shared
        info = []
        video_files.each do |file|
          info << file.short_info
        end

        info
      end

      ####################################class methods
      class << self
        def per_page(dialog = false)
          dialog ? Videos.pages_per_dialog : Videos.pages_per_admin_index
        end
      end
      #################################################

      private

      def set_default_config
        if new_record? && config.empty?
          CONFIG_OPTIONS.each do |option, value|
            self.send("#{option}=", value)
          end
        end
      end

      def update_from_config
        embed_tag.gsub!(/width="(\d*)?"/, "width=\"#{config[:width]}\"")
        embed_tag.gsub!(/height="(\d*)?"/, "height=\"#{config[:height]}\"")
        #fix iframe overlay
        if embed_tag.include? 'iframe'
          embed_tag =~ /src="(\S+)"/
          embed_tag.gsub!(/src="\S+"/, "src=\"#{$1}?wmode=transparent\"")
        end
      end

      def one_source
        errors.add(:embed_tag, 'Please embed video') if use_shared && embed_tag.nil?
        errors.add(:video_files, 'Please select at least one source') if !use_shared && video_files.empty?
      end

    end

  end
end
