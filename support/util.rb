class Util
#
# Description: To get unique series of number which can be used for data or time .
# Parameters:
#    prefix::  Data with which unique series of number to be postfix.
#
  def Util.unique(prefix = nil)
    postfix = Time.now.to_i.to_s + rand(0...800).to_s
    if prefix
      prefix + postfix
    else
      postfix
    end
  end

  #Used to write log messages.
  def Util.log(*args)
    msg, type = args
    type ||= 2
    case type
      when 1
        puts "\s\s\s\s\s\s[DEBUG]: #{msg}" if MESSAGE == 'DEBUG'
      when 2
        puts "\s\s\s\s\s\s[INFO]: #{msg}" unless MESSAGE == 'NONE'
      else
        raise "Undefined type [#{type}]"
    end
  end

  #
  # Description: Used to assert an script execution based on provided data & condition
  # Parameters:
  #    test::  Test Script reference
  #    message:: Message to be added while asserting
  #
  def Util.assert(test, message = nil)
    if (!test)
      message ||= "Assert failed."
      Util.log_steps(message, "FAIL", false)
      raise message unless test
    else
      $stepstatus = 'pass'
    end
  end

  #
  # Description: Used to assert an script execution based on provided data & condition
  # Parameters:
  #    test::  Test Script reference
  #    message:: Message to be added while asserting
  #
  def Util.soft_assert(test, message = nil)
    if (!test)
      message ||= "Assert failed."
      Util.log_steps("Assert failed. #{message}", "INFO", false)
      $stepstatus = 'fail_soft'
    else
      $stepstatus = 'pass'
    end
  end

  #
  # Description: Used to assert an script based on equality of provided two data.
  # Parameters:
  #    actual::  actual data
  #    expect:: expected data
  #
  def Util.assert_equal(actual, expect)
    if (actual == expect)
      $stepstatus = 'pass'
    end
    Util.assert(actual == expect, "Expected value [#{expect}] doesn't match actual value [#{actual}].")
  end

  #
  # Description: Used to assert an script based on non-equality of provided two data.
  # Parameters:
  #    actual::  actual data
  #    expect:: expected data
  #
  def Util.assert_not_equal (actual, expect)
    if (actual != expect)
      $stepstatus = 'pass'
    end
    Util.assert(actual != expect, "Expected value [#{expect}] shouldn't match actual value [#{actual}].")
  end

  #
  # Description: Used to assert an script execution based on provided data & condition
  # Parameters:
  #   args:: SQL Query and expected query output.
  #
  def Util.assert_data(*args)
    query, expect = args
    if query.include?('COUNT(*)')
      actual = Util.db(query)[0].to_i
      if (expect.kind_of?(Array)) ? (expect = expect[0]) : (expect = expect)
        if expect.to_s.include?('!')
          Util.assert_not_equal(actual, expect.sub!("!", "").to_i)
        else
          Util.assert_equal(actual, expect.to_i)
        end
      end
    else
      if (expect.kind_of?(Array)) ? (expect = expect) : (expect = expect.strip.split(','))
        actual = Util.db(query)
        j = 0
        if actual.nil? || actual.empty?
          raise "No returned data"
        else
          actual.each {|row|
            if row.kind_of?(DBI::Row)
              for i in 0..(expect.length - 1)
                if expect[i].to_s.include?('%')
                  Util.assert row[i].to_s.include?(expect[i].to_s.sub!('%', '')), "Expected value [#{expect[i]}] does not match actual value [#{row[i]}]."
                else
                  if row[i].kind_of?(String)
                    Util.assert_equal(row[i].to_s, expect[i].to_s)
                  else
                    Util.assert_equal(row[i].to_i, expect[i].to_i)
                  end
                end
              end
            else
              if expect[j].to_s.include?('%')
                Util.assert row.to_s.include?(expect[j].to_s.sub!('%', '')), "Expected value [#{expect[j]}] does not match actual value [#{row}]."
              else
                if row.kind_of?(String)
                  Util.assert_equal(row.to_s, expect[j].to_s)
                elsif row.kind_of?(Array)
                  Util.assert_equal(row[0].to_s, expect[j].to_s)
                else
                  Util.assert_equal(row.to_f, expect[j].to_f)
                end
              end
              j += 1
            end
          }
        end
      end
    end
  end

  #
  # Description: Used to look up for index on breadcrum / add or remove address
  # Parameters:
  #   pattern:: locator patter
  #   match:: to be considered as matching text
  #   match_type:: text
  #   match_method:: exact
  #   attribute:: attribute value
  #
  def Util.index_lookup(pattern, match, match_type = :text, match_method = :exact, attribute = nil)
    index = nil
    (1..10).each {|i|
      index = i.to_s
      new_pattern = pattern.sub("$", index)
      begin
        match_type == :text ? text = $app.get_text(new_pattern, "pattern") : text = $app.get_value(new_pattern, "attribute_value", attribute)
      rescue
        text = 'false'
      ensure
        if match_method == :exact
          break if text == match.to_s
        else
          break if text.include?(match.to_s)
        end
      end
    }
    index
  end
end

#
# Adds log based on the type of log
# Parameters:
#  log_msg:: The message which is intended to be displayed
#  log_type:: Type of log (STEP, INFO,FAIL, WARN, etc)
#  log_screenshot:: Take screenshot or not (false/true)
# Example:
#  Util.log_steps("Log this", "INFO", false)
#  Util.log_steps("Log this", "FAIL", true)
#  Util.log_steps("Log this", "WARN", true)
#
def Util.log_steps(log_msg = nil, log_type = "INFO", log_screenshot = false, step_code = nil)

  if $do_log == "true"
    log_screenshot ||= false
    if log_screenshot == true
      begin
        name = $scenario.name
      rescue
        name = $scenario.scenario_outline.name
      end
    end

    case log_type.upcase
      when "TEST_CASE_INFO"
        puts "#{Util.get_time_stamp} \s\s#{log_msg}"

      when "STEP"
        if step_code.nil?
          puts "#{Util.get_time_stamp}[STEP]: #{log_msg}"
        else
          puts "#{Util.get_time_stamp} \s\s\s#{step_code}[STEP]: #{log_msg}"
        end

      when "INFO"
        puts "#{Util.get_time_stamp} \s\s\s\s\s\s\s\s\s[INFO]: #{log_msg}"
        if !(@driver.nil?) and log_screenshot == true
          @driver.screenshot(name)
        end

      when "FAIL"
        $stepstatus = 'FAIL'
        puts "#{Util.get_time_stamp} \s\s\s\s\s\s\s\s\s[FAIL]: #{log_msg}"

      when "FAIL_SOFT"
        puts "#{Util.get_time_stamp} \s\s\s\s\s\s\s\s\s[FAIL]: #{log_msg}"
        $stepstatus = 'fail_soft'

      when "DEBUG"
        puts "#{Util.get_time_stamp} \s\s\s\s\s\s\s\s\s[DEBUG]: #{log_msg}"
        if !(@driver.nil?) and log_screenshot == true
          @driver.screenshot(name)
        end

      when "WARN"
        puts "#{Util.get_time_stamp} \s\s\s\s\s\s\s\s\s[WARN]: #{log_msg}"
        warn "\s\s\s\s\s\s\s\s\s[WARN]: #{log_msg}"
        if !(@driver.nil?) and log_screenshot == true
          @driver.screenshot(name)
        end
      when "REPORT"
    end
  end
end

def Util.get_time_stamp
  "#{Time.now.strftime('%T')}"
end

def Util.get_date_time_stamp
  "#{Time.now.strftime('%D')} #{Util.get_time_stamp}"
end
