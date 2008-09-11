require File.dirname(__FILE__) + '/spec_helper.rb'

include RR

describe ScanSummaryReporter do
  before(:each) do
    $stdout.should_receive(:puts).any_number_of_times
  end

  it "should register itself with ScanRunner" do
    ScanReportPrinters.report_printers.any? do |printer|
      printer[:printer_class] == ScanSummaryReporter
    end.should be_true
  end
  
  it "initialize should detect if the detailed number of differnces should be counted" do
    ScanSummaryReporter.new(nil).only_totals.should be_true
    ScanSummaryReporter.new("bla").only_totals.should be_true
    ScanSummaryReporter.new("detailed").only_totals.should be_false
  end
  
  it "scan should count differences correctly in totals mode" do
    org_stdout = $stdout
    $stdout = StringIO.new
    begin
      reporter = ScanSummaryReporter.new(nil)
      
      # set some existing scan result to ensure it gets reset before the next run
      reporter.scan_result = {:conflict => 0, :left => 0, :right => 1}
      
      reporter.scan('left_table', 'right_table') do 
        reporter.report_difference :conflict, :dummy_row
        reporter.report_difference :left, :dummy_row
        reporter.report_difference :right, :dummy_row
      end
      $stdout.string.should == "left_table / right_table 3\n"
    ensure 
      $stdout = org_stdout
    end
  end

  it "scan should count differences correctly in detailed mode" do
    org_stdout = $stdout
    $stdout = StringIO.new
    begin
      reporter = ScanSummaryReporter.new("detailed")
      
      reporter.scan('left_table', 'right_table') do 
        reporter.report_difference :conflict, :dummy_row
        reporter.report_difference :left, :dummy_row
        reporter.report_difference :left, :dummy_row
        reporter.report_difference :right, :dummy_row
        reporter.report_difference :right, :dummy_row
        reporter.report_difference :right, :dummy_row
      end
      $stdout.string.should == "left_table / right_table 1 2 3\n"
    ensure 
      $stdout = org_stdout
    end
  end
end