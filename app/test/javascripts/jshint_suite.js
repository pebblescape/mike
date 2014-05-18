// Teaspoon includes some support files, but you can use anything from your own support path too.
//= require support/sinon
//= require support/helpers
//= require support/qunit_helpers
//
// PhantomJS (Teaspoons default driver) doesn't have support for Function.prototype.bind, which has caused confusion.
// Use this polyfill to avoid the confusion.
//= require support/bind-poly
//
//= require vendor
//= require ../../app/assets/javascripts/locales/en
//= require preloader
//= require application
//= require jshint
//= require_self
//= require jshint_all

Mike.setupForTesting();
Mike.injectTestHelpers();
Mike.deferReadiness();