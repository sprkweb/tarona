var NewGame = function() {
  var expires = (new Date('1')).toUTCString();
  document.cookie = 'session_id=; expires: ' + expires;
  location.href = './play';
};

if (typeof environment === 'undefined') {
  var environment = 'production';
}

if (environment !== 'test') {
  NewGame();
}
