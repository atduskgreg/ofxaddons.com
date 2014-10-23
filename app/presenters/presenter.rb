class Presenter < SimpleDelegator

  def initialize(object, template)
    @template = template
    super(object)
  end

private

  def h
    @template
  end

  def object
    __getobj__
  end

end
