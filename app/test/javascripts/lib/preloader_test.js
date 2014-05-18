module("Mike.Preloader", {
  setup: function() {
    Preloader.store('bane', 'evil');
  }
});

test("get", function() {
  blank(Preloader.get('joker'), "returns blank for a missing key");
  equal(Preloader.get('bane'), 'evil', "returns the value for that key");
});

test("remove", function() {
  Preloader.remove('bane');
  blank(Preloader.get('bane'), "removes the value if the key exists");
});

asyncTestMike("getAndRemove returns a promise that resolves to null", function() {
  expect(1);

  Preloader.getAndRemove('joker').then(function(result) {
    blank(result);
    start();
  });
});

asyncTestMike("getAndRemove returns a promise that resolves to the result of the finder", function() {
  expect(1);

  var finder = function() { return 'batdance'; };
  Preloader.getAndRemove('joker', finder).then(function(result) {
    equal(result, 'batdance');
    start();
  });

});

asyncTestMike("getAndRemove returns a promise that resolves to the result of the finder's promise", function() {
  expect(1);

  var finder = function() {
    return Ember.Deferred.promise(function(promise) { promise.resolve('hahahah'); });
  };

  Preloader.getAndRemove('joker', finder).then(function(result) {
    equal(result, 'hahahah');
    start();
  });
});

asyncTestMike("returns a promise that rejects with the result of the finder's rejected promise", function() {
  expect(1);

  var finder = function() {
    return Ember.Deferred.promise(function(promise) { promise.reject('error'); });
  };

  Preloader.getAndRemove('joker', finder).then(null, function(result) {
    equal(result, 'error');
    start();
  });

});

asyncTestMike("returns a promise that resolves to 'evil'", function() {
  expect(1);

  Preloader.getAndRemove('bane').then(function(result) {
    equal(result, 'evil');
    start();
  });
});
