class Evt::Kqueue < Evt::Bundled
  def self.available?
    self.respond_to?(:kqueue_backend)
  end

  def self.backend
    self.kqueue_backend
  end

  def initialize
    super
  end

  def init_selector
    kqueue_init_selector
  end

  def register(io, interest)
    kqueue_register(io, interest)
  end

  def deregister(io)
    # Placeholder
  end

  def wait
    kqueue_wait
  end
end
