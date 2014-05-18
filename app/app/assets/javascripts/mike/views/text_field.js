Mike.TextField = Ember.TextField.extend({
  attributeBindings: ['autocorrect', 'autocapitalize', 'autofocus'],

  placeholder: function() {
    if (this.get('placeholderKey')) {
      return I18n.t(this.get('placeholderKey'));
    } else {
      return '';
    }
  }.property('placeholderKey')

});

Em.View.registerHelper('textField', Mike.TextField);