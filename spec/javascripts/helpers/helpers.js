/**
 * Create fake event and run it.
 * @param target {Element} - element which will receive the event
 * @param event {String} - name of the event, e. g. click
 * @param additions {?object} - properties of the event, e.g. clientX
 * @return {CustomEvent} the event
 */
var RunFakeUserAction = function(target, event_name, additions) {
  var ev = document.createEvent('CustomEvent');
  ev.initEvent(event_name, true, false, null);
  if (additions) _.extend(ev, additions);
  target.dispatchEvent(ev);
  return ev;
};
