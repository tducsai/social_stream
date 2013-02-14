class Audio < Document  
  has_attached_file :file, 
                    :url => '/:class/:id.:content_type_extension',
                    :path => ':rails_root/documents/:class/:id_partition/:style',
                    :styles => SocialStream::Documents.audio_styles,
                    :processors => [ :ffmpeg, :waveform ]
  
  process_in_background :file    
end
