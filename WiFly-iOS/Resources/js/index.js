(function () {

  window.onload = function () {
    getHostName();
    eventsHandler();
  }

  function getHostName () {
    $.get(location.href + ':12580/id', function (data) {
      if (data) {
        $('#submit').text('UPLOAD TO "' + data + '"');
      }
    });
  }

  function eventsHandler () {
    $('#submit').on('click', showFiles);
    $('#file').on('change', startUpload);
  }

  function showFiles () {
    $('#file').click();
  }

  function startUpload (e) {
    var file = e.target.files[0];
    if (file) {
      toggleSubmitDisabled(true);
      toggleHint(false);
      appendList(file);
      startRequest(file);
    }
  }

  function appendList (file) {
    var dom = $(Template['web-upload-item']);
    dom.attr('id', 'list-processing');
    dom.find('.list-name').text(file.name);
    dom.find('.list-status').text('requesting...');
    $('.list-main').prepend(dom);
  }

  function startRequest (file) {
    var data = new FormData();
    data.append('file', file);
    data.append('name', file.name);
    data.append('size', file.size);
    data.append('type', file.type);
    data.append('from', 'web');
    $.ajax({
      url : location.href.substring(0, location.href.length - 7) + '/upload',
      type : 'POST',
      data : data,
      processData : false,
      contentType : false,
      error : function (data) {
        $('#list-processing').find('.list-status').addClass('list-status-error').text('error');
        $('#list-processing').removeAttr('id');
        toggleSubmitDisabled(false);
        $('#file').val('');
      },
      success : function (data) {
        $('#list-processing').find('.list-status').addClass('list-status-success').text('√');
        $('#list-processing').removeAttr('id');
        toggleSubmitDisabled(false);
        $('#file').val('');
      },
      xhr : function () {
        var xhr = $.ajaxSettings.xhr();
        xhr.upload.onprogress = function (progress) {
          var percentage = Math.floor(progress.loaded / progress.total * 100);
          $('#list-processing').find('.list-status').text('uploading: ' + percentage + '%');
        }
        xhr.upload.onload = function () {
          $('#list-processing').find('.list-status').text('waiting...');
        }
        return xhr;
      }
    });
  }

  function toggleSubmitDisabled (disabled) {
    if (disabled) {
      $('#submit').attr('disabled', true);
    } else {
      $('#submit').removeAttr('disabled');
    }
  }

  function toggleHint(show) {
    if (show) {
      $('.list-hint').show();
    } else {
      $('.list-hint').hide();
    }
  }

})();