// Teaspoon includes some support files, but you can use anything from your own support path too.
//= require support/sinon
//= require support/helpers
//= require support/qunit_helpers
//
// PhantomJS (Teaspoons default driver) doesn't have support for Function.prototype.bind, which has caused confusion.
// Use this polyfill to avoid the confusion.
//= require support/bind-poly
//
// Deferring execution
// If you're using CommonJS, RequireJS or some other asynchronous library you can defer execution. Call
// Teaspoon.execute() after everything has been loaded. Simple example of a timeout:
//
// Teaspoon.defer = true
// setTimeout(Teaspoon.execute, 1000)
//
// Matching files
// By default Teaspoon will look for files that match _test.{js,js.coffee,.coffee}. Add a filename_test.js file in your
// test path and it'll be included in the default suite automatically. If you want to customize suites, check out the
// configuration in config/initializers/teaspoon.rb
//
// Manifest
// If you'd rather require your test files manually (to control order for instance) you can disable the suite matcher in
// the configuration and use this file as a manifest.
//
// For more information: http://github.com/modeset/teaspoon
//
// You can require your own javascript files here. By default this will include everything in application, however you
// may get better load performance if you require the specific files that are being used in the test that tests them.
//= require vendor
//= require ../../app/assets/javascripts/locales/en
//= require preloader
//= require application
//= require_self

// Trick JSHint into allow document.write
var d = document;
d.write('<div id="ember-testing-container"><div id="ember-testing"></div></div>');
d.write('<style>#ember-testing-container { position: absolute; background: white; bottom: 0; right: 0; width: 600px; height: 338px; overflow: auto; z-index: 9999; border: 1px solid #ccc; opacity: 0.4; } #ember-testing-container:hover { opacity: 1.0; } #ember-testing { zoom: 50%; } </style>');

Mike.rootElement = '#ember-testing';
Mike.setupForTesting();
Mike.injectTestHelpers();
Mike.deferReadiness();

QUnit.testStart(function() {
//   // Allow our tests to change site settings and have them reset before the next test
//   Ping.Settings = jQuery.extend(true, {}, Ping.SettingsOriginal);
});