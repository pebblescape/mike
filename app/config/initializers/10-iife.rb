require 'mike_iife'

Rails.application.assets.register_preprocessor('application/javascript', MikeIIFE)