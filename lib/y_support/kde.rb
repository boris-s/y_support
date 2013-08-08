# encoding: utf-8

require 'y_support'

module YSupport::KDE
  class << self
    # Open a file with kioclient (using KDE file-viewer associations).
    # 
    def show_file_with_kioclient( fɴ_with_path )
      system "sleep 0.2; kioclient exec 'file:%s'" % fɴ_with_path
    end
  end
end # module YSupport::KDE
