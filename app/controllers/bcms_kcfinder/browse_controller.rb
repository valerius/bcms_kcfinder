module BcmsKcfinder
  class BrowseController < Cms::BaseController

    # This API is mostly JSON, so CSRF shouldn't be an issue.
    protect_from_forgery :except => [:download,:upload]
    
    layout 'bcms_kcfinder/application'
    before_filter :set_default_type
    before_filter :determine_current_section, :only=>[:init, :upload, :change_dir]

    def index
    end

    # At the start, the entire Sitemap tree has to be defined, though pages below the top level do not need to be included until a 'chDir'
    # command is issued.
    def init
      logger.warn "Use the right root section"
      @root_section = Cms::Section.root.first
      @section = Cms::Section.find_by_name_path("/")
      render :json => {tree: {name: @root_section.name,
                              readable: true,
                              writable: true,
                              removable: false,
                              current: true,
                              hasDirs: !@section.child_sections.empty?,
                              dirs: child_sections_to_dirs(@section)},
                       files: list_files(),
                       dirWritable: true}.to_json
    end

    def upload
      content_block = case params[:type].downcase
        when "files"
          create_new(Cms::FileBlock)
        when "images"
          create_new(Cms::ImageBlock)
      end
      render :text => content_block.path
    end

    def create_new(klass)
      uploaded_file = params[:upload].first
      f = klass.new(:name => uploaded_file.original_filename, :publish_on_save => true)
      a = f.attachments.build(:parent => @section,
                              :data_file_path => uploaded_file.original_filename,
                              :attachment_name => 'file',
                              :data => uploaded_file)
      f.save!
      f
    end

    # Change to a directory and return the files for that directory
    def change_dir
      render :json => {files: list_files(), dirWritable: true}.to_json
    end


    def download
      #raise "Error: The thumbnail comand '#{params[:command]}' is not implemented yet."
      file_path = params[:path]
      @attachment = Cms::Attachment.find_live_by_file_path(params[:path])
      send_file @attachment.path , :filename=>File.basename(file_path)

    end
    def thumb
      #raise "Error: The thumbnail comand '#{params[:command]}' is not implemented yet."
      @attachment = Cms::Attachment.find_live_by_file_path(params[:path])
      send_file @attachment.path(:thumb)
    end

    def command
      raise "Error: The command '#{params[:command]}' is not implemented yet."
    end

    private

    def determine_current_section
      unless params[:dir]
        params[:dir] = "My Site"
      end
      normalized_dir_name = params[:dir].gsub("My Site", "/")
      @section = Cms::Section.find_by_name_path(normalized_dir_name)
    end

    def set_default_type
      unless params[:type]
        params[:type] = "files"
      end
    end

    def list_files
      show = case params[:type]
               when "files"
                 @section.linkable_children
               when "images"
                 Cms::ImageBlock.by_section(@section)
               else
                 []
             end
      render_files(show)
    end

    def render_files(files)
      files.map do |file|
        {
            # Handle having a possibly 'null' data_file_name, which might happen if upgrades aren't successful.
            # Otherwise, the UI can't sort items correctly
            name: file.name ? file.name : "",
            size: file.size_in_bytes,
            path: file.link_to_path,
            mtime: file.updated_at.to_i,
            date: file.created_at.strftime("%m/%d/%Y %I:%M %p"),
            readable: BcmsKcfinder.config.readable,
            writeable:  BcmsKcfinder.config.writeable,
            bigIcon: BcmsKcfinder.config.bigIcon,
            smallIcon: BcmsKcfinder.config.smallIcon,
            thumb: BcmsKcfinder.config.thumbnail,
            smallThumb: BcmsKcfinder.config.smallThumb,
            cms_id: file.id
        }
      end
    end

    def child_sections_to_dirs(section)
      section.sections.map do |child|
        {
            name: child.name,
            readable:  BcmsKcfinder.config.dir_readable,
            writable:  BcmsKcfinder.config.dir_writable,
            removable:  BcmsKcfinder.config.dir_removable,
            hasDirs: !child.child_sections.empty?,
            current: false,
            dirs: child_sections_to_dirs(child)
        }
      end
    end
  end
end
