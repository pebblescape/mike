/* global asyncTest */
/* exported integration, testController, controllerFor, asyncTestMike */
function integration(name, lifecycle) {
  module("Integration: " + name, {
    setup: function() {
      Ember.run(Mike, Mike.advanceReadiness);

      if (lifecycle && lifecycle.setup) {
        lifecycle.setup.call(this);
      }
    },

    teardown: function() {
      if (lifecycle && lifecycle.teardown) {
        lifecycle.teardown.call(this);
      }

      Mike.reset();
    }
  });
}

function testController(klass, model) {
  return klass.create({model: model, container: Mike.__container__});
}

function controllerFor(controller, model) {
  controller = Mike.__container__.lookup('controller:' + controller);
  if (model) { controller.set('model', model ); }
  return controller;
}

function asyncTestMike(text, func) {
  asyncTest(text, function () {
    var self = this;
    Ember.run(function () {
      func.call(self);
    });
  });
}