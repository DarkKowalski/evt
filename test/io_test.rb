require "test_helper"

class TestIO < Minitest::Test
  MESSAGE = "Hello World"
  BATCH_SIZE = 16

  def test_read
    rd, wr = IO.pipe
    scheduler = Evt::Scheduler.new

    message = nil
    thread = Thread.new do
      Fiber.set_scheduler scheduler

      Fiber.schedule do
        message = rd.read(20)
        rd.close
      end

      Fiber.schedule do
        wr.write(MESSAGE)
        wr.close
      end

      scheduler.run
    end

    thread.join

    assert_equal MESSAGE, message
    assert rd.closed?
    assert wr.closed?
  end

  def test_batch_read
    ios = BATCH_SIZE.times.map { IO.pipe }
    results = []
    scheduler = Evt::Scheduler.new

    thread = Thread.new do
      Fiber.set_scheduler scheduler

      ios.each do |io|
        rd, wr = io
        Fiber.schedule do
          results << rd.read(20)
          rd.close
        end
  
        Fiber.schedule do
          wr.write(MESSAGE)
          wr.close
        end
      end

      scheduler.run
    end
    
    thread.join

    assert_equal BATCH_SIZE, results.length
    results.each do |message|
      assert_equal MESSAGE, message
    end
    ios.each do |io|
      rd, wr = io
      assert rd.closed?
      assert wr.closed?
    end
  end
end