module ServerHelper
  include EM::SpecHelper

  def as_server(&block)
    em do
      Server.context.start
      yield Server.context
      Server.context.stop
    end
  end
end