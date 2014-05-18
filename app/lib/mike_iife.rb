class MikeIIFE < Sprockets::Processor

  # Add a IIFE around our javascript
  def evaluate(context, locals)
    path = context.pathname.to_s
    
    # Only Mike paths
    return data unless (path =~ /\/javascripts\/mike/ || path =~ /\/test\/javascripts/)

    # Ignore the js helpers
    return data if (path =~ /test\_helper\.js/)
    return data if (path =~ /javascripts\/support\//)

    # We don't add IIFEs to handlebars
    return data if path =~ /\.hbs/

    "(function () {\n\nvar $ = window.jQuery;\n// IIFE Wrapped Content Begins:\n\n#{data}\n\n// IIFE Wrapped Content Ends\n\n })(this);"
  end

end