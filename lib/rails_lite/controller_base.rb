require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'


class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    self.req, self.res = req, res

    @already_built_response = false
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    raise RuntimeError if already_built_response?

    res.body, res.content_type = content, type
    response_built!
  end

  # helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # set the response status code and header
  def redirect_to(url)
    raise RuntimeError if already_built_response?

    res['location'] = url.to_s
    res.status = 302
    response_built!
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.name.underscore.gsub(/_controller$/,'')
    filename = "views/#{controller_name}/#{template_name}.html.erb"
    erb_data = File.read(filename)

    template = ERB.new(erb_data)
    rendered_template = template.result(instance_binding)

    render_content(rendered_template, "text/html")
  end

  # method exposing a `Session` object
  def session
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end

  private
  attr_writer :params, :req, :res

  def response_built!
    @already_built_response = true
  end

  # We want ivars only, not the calling method's local variables.
  def instance_binding
    binding
  end
end
