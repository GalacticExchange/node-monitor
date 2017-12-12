module HeadlessHelpers

  def use_headless

    unless Gem.win_platform?
      headless = Headless.new(dimensions: "1280x1200x24", display: 1, autopick: true, reuse: false, destroy_at_exit: true).start
    end

  end


end
