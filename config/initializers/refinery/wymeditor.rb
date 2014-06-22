Refinery::Wymeditor.configure do |config|
  # Add extra tags to the wymeditor whitelist e.g. = {'tag' => {'attributes': '1': 'href'}} or just {'tag' => {}}
  config.whitelist_tags = {
    'video' => {
      'attributes' => {
        '1' => 'controls',
        '2' => 'autoplay',
        '3' => 'preload',
        '4' => 'poster',
        '5' => 'loop',
        '6' => 'width',
        '7' => 'height',
      }
    },
    'source' => {
      'attributes' => {
        '1' => 'src',
        '2' => 'type'
      }
    }
  }
end
