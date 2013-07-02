# -*- coding: utf-8 -*-
require 'y_support'

module YSupport::KDE
  class << self
    # Open a file with kioclient (using KDE file-viewer associations).
    # 
    def show_file_with_kioclient( fɴ_with_path )
      system "sleep 0.2; kioclient exec 'file:%s'" % fɴ_with_path
    end

    # Dialog box querying for a string.
    # 
    def query_box( dialog_text, prompt: '> ', title_bar: 'User input required', &block )
      title_bar_text = title_bar
      prompt_label_text = prompt
      
      w = Gtk::Window.new( Gtk::Window::TOPLEVEL )
      w.set_title( title_bar_text )
      w.border_width = 10
      w.signal_connect 'delete_event' do Gtk.main_quit end               # cc
      
      tlabel_widget = Gtk::Label.new( dialog_text )
      plabel_widget = Gtk::Label.new( prompt_label_text )
      ebox_widget = Gtk::Entry.new
      ebox_widget.visibility = true                                      # cc
      
      hbox = Gtk::HBox.new(false, 5)                                     # cc
      hbox.pack_start_defaults( plabel_widget )                          # cc
      hbox.pack_start_defaults( ebox_widget )
      vbox = Gtk::VBox.new(false, 5)
      vbox.pack_start_defaults( tlabel_widget )
      vbox.pack_start_defaults( hbox )
      w.add(vbox)
      
      ebox_widget.signal_connect("key-release-event") do |sender, event| # cc
        kn = Gdk::Keyval.to_name(k = event.keyval)
        if kn == "Return"
          block.( sender.text )
          Gtk.main_quit
        end
      end

      w.show_all                                                         # cc
      Gtk.main
    end

    # Message box.
    # 
    def message_box( message="Press any key to close this window!" )
      w = Gtk::Window.new
      w.add_events Gdk::Event::KEY_PRESS
      w.add Gtk::Label.new( message )
      w.signal_connect "key-release-event" do Gtk.main_quit end
      w.set_default_size( 600, 120 ).show_all
      Gtk.main
    end
  end
end # module YSupport::KDE
