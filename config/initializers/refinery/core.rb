Refinery::Core.configure do |config|
  # Register extra sstylesheets and javascripts for backend.
  config.register_stylesheet "refinery/admin/video.css"
  config.register_javascript "refinery/admin/wymeditor_monkeypatch.js"
  config.register_javascript "video.js"
  config.register_javascript "youtube.js"
end
