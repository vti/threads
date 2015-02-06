(function(){

    this.ValueObject = function() {
        this.attrs = {};
    };

    ValueObject.prototype.set = function(key, value) {
        this.attrs[key] = value;
    };

    ValueObject.prototype.get = function(key) {
        return this.attrs[key];
    };

    this.ValueObjectObservable = function() {
        this.observers = {};
        ValueObject.call(this);
    };
    ValueObjectObservable.prototype = Object.create(ValueObject.prototype);
    ValueObjectObservable.prototype.constructor = ValueObjectObservable;

    ValueObjectObservable.prototype.set = function(key, value) {
        var old = this.get(key);

        ValueObject.prototype.set.apply(this, arguments);

        if (old != value) {
            this.notify(key, value);
        }
    };

    ValueObjectObservable.prototype.get = function(key) {
        return ValueObject.prototype.get.apply(this, arguments);
    };

    ValueObjectObservable.prototype.onchange = function(key, fn) {
        if (typeof this.observers[key] === 'undefined')
            this.observers[key] = [];
        this.observers[key].push(fn);
    };

    ValueObjectObservable.prototype.notify = function(key) {
        if (this.observers.hasOwnProperty(key)) {
            var observers = this.observers[key];

            var args = Array.prototype.slice.call(arguments, 1);
            for (var i = 0; i < observers.length; i++) {
                observers[i].apply(null, args);
            }
        }
    };

})();
