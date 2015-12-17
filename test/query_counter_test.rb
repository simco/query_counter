require 'test_helper'

class QueryCounterTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, QueryCounter
  end

  test "started? return false if counter is stopped" do
    ActiveRecord::QueryCounter.instance.stop
    assert_equal false, ActiveRecord::QueryCounter.instance.started?
  end

  test "started? return true if counter is started" do
    ActiveRecord::QueryCounter.instance.start
    assert_equal true, ActiveRecord::QueryCounter.instance.started?
  end

  test "reset method reset the count to zero" do
    ActiveRecord::QueryCounter.instance.reset
    assert_equal 0, ActiveRecord::QueryCounter.instance.count
  end

  test "using invalid count name returns zero" do
    assert_equal 0, ActiveRecord::QueryCounter.instance.count('inexistant_counter_name')
  end

  test "show counter exist and is incremented" do
    ActiveRecord::QueryCounter.instance.start
    ActiveRecord::QueryCounter.instance.reset
    Status.send :reset_column_information
    Status.first   # arel_table will trigger a new show the first time it is used
    assert ActiveRecord::QueryCounter.instance.count('show').is_a? Numeric
    assert 0 < ActiveRecord::QueryCounter.instance.count('show'), "Counter 'show' should have been greater then 0 but was #{ActiveRecord::QueryCounter.instance.count('show')}"
  end

  test "quering active record data increment counter by one" do
    ActiveRecord::QueryCounter.instance.start
    ActiveRecord::QueryCounter.instance.reset
    assert_equal 2, Status.count
    assert_equal 1, ActiveRecord::QueryCounter.instance.count
  end

  test "sql select operation increment counter select counter by one" do
    ActiveRecord::QueryCounter.instance.start
    ActiveRecord::QueryCounter.instance.reset
    Status.first
    assert_equal 1, ActiveRecord::QueryCounter.instance.count('select')
    assert_equal 0, ActiveRecord::QueryCounter.instance.count('update')
    assert_equal 0, ActiveRecord::QueryCounter.instance.count('insert')
    assert_equal 0, ActiveRecord::QueryCounter.instance.count('delete')
  end

  test "first sql select does show command, ignored by total count" do
    ActiveRecord::QueryCounter.instance.start
    ActiveRecord::QueryCounter.instance.reset
    Status.first
    assert_equal 1, ActiveRecord::QueryCounter.instance.count
    assert_equal 1, ActiveRecord::QueryCounter.instance.count('select')
  end

  test "select operation increment select counter by one" do
    ActiveRecord::QueryCounter.instance.start
    current_count = ActiveRecord::QueryCounter.instance.count('select')
    Status.first
    assert_equal current_count + 1, ActiveRecord::QueryCounter.instance.count('select')
  end

  test "two select operations increment select counter by two" do
    ActiveRecord::QueryCounter.instance.start
    current_select_count = ActiveRecord::QueryCounter.instance.count('select')
    current_count = ActiveRecord::QueryCounter.instance.count
    Status.first
    CustomStatus.first
    assert_equal current_select_count + 2, ActiveRecord::QueryCounter.instance.count('select')
    assert_equal current_count + 2, ActiveRecord::QueryCounter.instance.count
  end

  test "insert a record increment insert counter by one" do
    ActiveRecord::QueryCounter.instance.start
    current_insert_count = ActiveRecord::QueryCounter.instance.count('insert')
    current_count = ActiveRecord::QueryCounter.instance.count

    assert Status.create(name: 'fake'), "new status 'fake' failed to be created"
    
    assert_equal current_insert_count + 1 , ActiveRecord::QueryCounter.instance.count('insert')
    assert_equal current_count + 1, ActiveRecord::QueryCounter.instance.count

    ## second insert increment with bang
    assert Status.create!(name: 'fake 2'), "new status 'fake' failed to be created"
    
    assert_equal current_insert_count + 2 , ActiveRecord::QueryCounter.instance.count('insert')
    assert_equal current_count + 2, ActiveRecord::QueryCounter.instance.count
  end

  test "update a record increment update counter by one" do
    ActiveRecord::QueryCounter.instance.start
    status = Status.first

    current_update_count = ActiveRecord::QueryCounter.instance.count('update')
    current_count = ActiveRecord::QueryCounter.instance.count

    assert status.update_attributes(name: 'partially open')
    
    assert_equal current_update_count + 1 , ActiveRecord::QueryCounter.instance.count('update')
    assert_equal current_count + 1, ActiveRecord::QueryCounter.instance.count

    ## second update increment with bang
    assert status.update_attributes!(name: 'totally open')
    
    assert_equal current_update_count + 2 , ActiveRecord::QueryCounter.instance.count('update')
    assert_equal current_count + 2, ActiveRecord::QueryCounter.instance.count
  end

  test "delete a record increment delete counter by one" do
    ActiveRecord::QueryCounter.instance.start
    status1 = Status.first
    status2 = Status.last

    current_delete_count = ActiveRecord::QueryCounter.instance.count('delete')
    current_count = ActiveRecord::QueryCounter.instance.count

    assert status1.destroy
    
    assert_equal current_delete_count + 1 , ActiveRecord::QueryCounter.instance.count('delete')
    assert_equal current_count + 1, ActiveRecord::QueryCounter.instance.count

    ## second delete increment, with bang
    assert status2.destroy!
    
    assert_equal current_delete_count + 2 , ActiveRecord::QueryCounter.instance.count('delete')
    assert_equal current_count + 2, ActiveRecord::QueryCounter.instance.count
  end


  test "select counter is not incremented when counter is stoped" do
    ActiveRecord::QueryCounter.instance.stop
  
    current_select_count = ActiveRecord::QueryCounter.instance.count('select')
    current_count = ActiveRecord::QueryCounter.instance.count

    Status.first

    assert_equal current_select_count, ActiveRecord::QueryCounter.instance.count('select')
    assert_equal current_count, ActiveRecord::QueryCounter.instance.count
  end

  test "insert counter is not incremented when counter is stoped" do
    ActiveRecord::QueryCounter.instance.stop
  
    current_insert_count = ActiveRecord::QueryCounter.instance.count('insert')
    current_count = ActiveRecord::QueryCounter.instance.count

    assert Status.create(name: 'fake'), "new status 'fake' failed to be created"

    assert_equal current_insert_count, ActiveRecord::QueryCounter.instance.count('insert')
    assert_equal current_count, ActiveRecord::QueryCounter.instance.count
  end

  test "update counter is not incremented when counter is stoped" do
    ActiveRecord::QueryCounter.instance.stop

    status = Status.first
  
    current_update_count = ActiveRecord::QueryCounter.instance.count('update')
    current_count = ActiveRecord::QueryCounter.instance.count

    assert status.update_attributes(name: 'partially open'), "Status failed to be updated"

    assert_equal current_update_count, ActiveRecord::QueryCounter.instance.count('update')
    assert_equal current_count, ActiveRecord::QueryCounter.instance.count
  end

  test "delete counter is not incremented when counter is stoped" do
    ActiveRecord::QueryCounter.instance.stop

    status = Status.first
  
    current_delete_count = ActiveRecord::QueryCounter.instance.count('delete')
    current_count = ActiveRecord::QueryCounter.instance.count

    assert status.destroy, "Status failed to be destroyed"

    assert_equal current_delete_count, ActiveRecord::QueryCounter.instance.count('delete')
    assert_equal current_count, ActiveRecord::QueryCounter.instance.count
  end

  test "restart will reset counter and ensure that it is started" do
    # setup
    ActiveRecord::QueryCounter.instance.reset
    ActiveRecord::QueryCounter.instance.start

    Status.count
    assert_equal 1, ActiveRecord::QueryCounter.instance.count

    ActiveRecord::QueryCounter.instance.stop
    assert !ActiveRecord::QueryCounter.instance.started?

    # main test
    ActiveRecord::QueryCounter.instance.restart
    Status.first

    # validate
    assert ActiveRecord::QueryCounter.instance.started?
    assert_equal 1, ActiveRecord::QueryCounter.instance.count
  end

  test "within will start and stop a new query_counter" do
    ActiveRecord::QueryCounter.instance.reset
    ActiveRecord::QueryCounter.instance.start

    Status.count
    assert_equal 1, ActiveRecord::QueryCounter.instance.count

    ActiveRecord::QueryCounter.instance.stop
    assert !ActiveRecord::QueryCounter.instance.started?
    
    ActiveRecord::QueryCounter.instance.within do
      assert ActiveRecord::QueryCounter.instance.started?
      assert_equal 0, ActiveRecord::QueryCounter.instance.count

      Status.first

      assert_equal 1, ActiveRecord::QueryCounter.instance.count
    end

    assert !ActiveRecord::QueryCounter.instance.started?
  end
end
