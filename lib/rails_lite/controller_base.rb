require 'erb'
require 'active_support/inflector'
require_relative '../rails_lite'

class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    self.req, self.res = req, res
    self.params = Params.new(req, route_params)

    @already_built_response = false
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    raise RuntimeError if already_built_response?

    res.body, res.content_type = content, type
    session.store_session(res)

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
    session.store_session(res)

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
    @session ||= Session.new(req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    send(name)
    render(name.to_s) unless already_built_response?
  end

  protected
  attr_writer :params, :req, :res

  def response_built!
    @already_built_response = true
  end

  # We want ivars only, not the calling method's local variables.
  def instance_binding
    binding
  end
end
