(function() {
  var expires = (new Date('1')).toUTCString();
  document.cookie = 'session_id=; expires: ' + expires;
  location.href = './play';
})();
