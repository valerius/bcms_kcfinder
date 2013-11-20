module BcmsKcfinder


  def self.config
    @config ||= Config.new
  end

  def self.configure
    @config = Config.new
    yield(@config)

  end

  class Config
    attr_accessor :enabled, :thumbnail , :readable, :bigIcon , :smallIcon , :smallThumb , :writeable,
                  :dir_readable,:dir_writable,:dir_removable

    def initialize
      @enabled = true
      @thumbnail = true

      @readable= true
      @bigIcon = true
      @smallIcon = true
      @smallThumb = false
      @writeable = true


      @dir_readable = true
      @dir_writable = true
      @dir_removable = true
    end

  end
end
