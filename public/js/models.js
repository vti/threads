(function(){

    this.Observer = function() {
        this.attrs = {};
        this.attrs.on = {};
    };

    Observer.prototype.on = function(name, cb) {
        this.attrs.on[name] = cb;
    };

    Observer.prototype.events = function() {
        var keys = [];
        for (var k in this.attrs.on) keys.push(k);
        return keys;
    };

    Observer.prototype.notify = function(name) {
        var args = Array.prototype.slice.call(arguments, 1);
        this.attrs.on[name].apply(null, args);
    };

    this.NotificationCount = function() {
        this.attrs = {};
        this.observers = [];
    };

    NotificationCount.prototype.set = function(key, value) {
        this.attrs[key] = value;

        this.notify('set:' + key, value);
    };

    NotificationCount.prototype.get = function(key) {
        return this.attrs.key;
    };

    NotificationCount.prototype.observe = function(object) {
        var events = object.events();
        for (var i = 0; i < events.length; i++) {
            var name = events[i];
            this.observers.push({name: name, object: object});
        }
    };

    NotificationCount.prototype.notify = function() {
        var name = arguments[0];
        for (var i = 0; i < this.observers.length; i++) {
            var observer = this.observers[i];
            if (observer.name == name) {
                observer.object.notify.apply(observer.object, arguments);
            }
        }
    };

})();
