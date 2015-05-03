var Template = {
  'device-item' : ['<li class="device-item">',
    '<img src="" alt="" class="device-icon">',
    '<p>',
      '<span class="device-name"></span>',
      '<span class="device-ip"></span>',
    '</p>',
    '<p>',
      '<span class="device-status"></span>',
      '<span class="device-progress-outer">',
        '<span class="device-progress-inner"></span>',
      '</span>',
      '<span class="device-percentage"></span>',
      '<button class="device-send"></button>',
    '</p>',
  '</li>'].join(''),

  'received-item' : ['<li class="received-item">',
    '<span class="received-icon"></span>',
    '<span class="received-name"></span>',
    '<span class="received-size"></span>',
    '<span class="received-time"></span>',
  '</li>'].join(''),

  'web-upload-item' : ['<li class="list-item">',
    '<span class="list-name"></span>',
    '<span class="list-status"></span>',
  '</li>'].join('')
};