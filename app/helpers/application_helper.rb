module ApplicationHelper
  def if_owner(resource, &block)
    block.call if owner_of?(resource)
  end

  def owns_any?(*resources)
    resources.any? { |resource| owner_of?(resource) }
  end

  def owns_all?(*resources)
    resources.all? { |resource| owner_of?(resource) }
  end
end
