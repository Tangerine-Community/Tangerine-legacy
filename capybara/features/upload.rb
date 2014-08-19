require 'rest-client'

describe "uploader view", :type => :feature do

	before do
    server_login()
    sleep 5
    click_button "alex_tests"
    sleep 10
  end

  good_test = 'Assessment Name,,,,
,prototype,assessment,,
,,,,
,,,,
Student Survey,,,,
,prototype,survey,,
,favorite_letter,,,
,,prompt,Which letter do you like most,
,,type,single,
,,options,,
,,,label,value
,,,a,1
,,,b,2
,,,c,3
,,,d,4
,,,e,5
,disliked_letters,,,
,,prompt,Which letters do you dislike,
,,type,multiple,
,,options,,
,,,label,value
,,,w,1
,,,x,2
,,,y,3
,,,z,4
,third_question,,,
,,prompt,Do you want to answer a third question?,
,,options,,
,,,yes,1
,,,no,0
,,,,
,,,,
Letter Identification,,,,
,variableName,letter_id,,
,prototype,grid,,
,items,a b c d e f g,,
,autostop,1,,
,timer,60,,,language,111342,,'

bad_test = 'Assessment Name,,,,
,prototype,assessment,,
,,,,
,,,,
Student Survey,,,,
,prototype,survey,,
,favorite_letter,,,
,,prompt,Which letter do you like most,
,type,single,
,,options,,
,,,label,value
,,,a,1
,,,b,2
,,,c,3
,,,d,4
,,,e,5
,disliked_letters,,,
,,prompt,Which letters do you dislike,
,,type,multiple,
,,options,,
,,label,value
,,,w,1
,,,x,2
,,,y,3
,,,z,4
,third_question,,,
,,prompt,Do you want to answer a third question?,
,,options,,
,,,yes,1
,,,no,0
,,,,
,,,,
Letter Identification,,,,
,variableName,letter_id,,
prototype,grid,,
,items,a b c d e f g,,
,autostop,1,,
,timer,60,,,
,language,111342,,'

	it "should have basic page elements" do
    page.find(".command.upload").click
		expect(page).to have_css "#subtest-panel"
		expect(page.find("#number-subtests-loaded")).to have_content "0"	
    expect(page).to have_css "#question-panel"
		expect(page.find("#number-questions-loaded")).to have_content "0"
		expect(page).to have_css "#option-panel"
		expect(page.find("#number-options-loaded")).to have_content "0"
    expect(page).to have_no_css '#error-panel'
    expect(page).to have_no_css "#save-button"
  end

  it "should gracefully handle verifying an empty test" do
    page.find(".command.upload").click
    page.find("#verify-button").click
    expect(page).to have_css "#subtest-panel"
    expect(page.find("#number-subtests-loaded")).to have_content "0"  
    expect(page).to have_css "#question-panel"
    expect(page.find("#number-questions-loaded")).to have_content "0"
    expect(page).to have_css "#option-panel"
    expect(page.find("#number-options-loaded")).to have_content "0"
    expect(page).to have_no_css '#error-panel'
    expect(page).to have_no_css "#save-button"
  end

  it "should refuse bad tests" do 
    page.find(".command.upload").click
    fill_in 'data', :with => bad_test
    sleep 1
    page.find("#verify-button").click

    expect(page.find("#number-subtests-loaded")).to have_content "0"  
    expect(page.find("#number-questions-loaded")).to have_content "0"
    expect(page.find("#number-options-loaded")).to have_content "0"
    expect(page).to have_content 'Verify'
    expect(page).to have_no_content 'Save Assessment'
    expect(page).to have_css "#error-panel"
    expect(page.find("#num_errors")).to have_content "2"

    fill_in 'data', :with => good_test
    page.find("#verify-button").click
    sleep 1
    expect(page.find("#number-subtests-loaded")).to have_content "2"
    expect(page.find("#number-questions-loaded")).to have_content "3"
    expect(page.find("#number-options-loaded")).to have_content "11"
    expect(page).to have_no_css "#verify-button"
    expect(page).to have_no_css '#error-panel'
    expect(page).to have_css '#save-button'
  end


  it "should verify correct tests" do
    page.find(".command.upload").click
    fill_in 'data', :with => good_test
  	page.find("#verify-button").click
  	sleep 1
		expect(page.find("#number-subtests-loaded")).to have_content "2"
		expect(page.find("#number-questions-loaded")).to have_content "3"
  	expect(page.find("#number-options-loaded")).to have_content "11"
  	expect(page).to have_no_css "#verify-button"
  	expect(page).to have_no_css '#error-panel'
  	expect(page).to have_css '#save-button'
    page.find("#save-button").click
  end
  
  it "should run saved tests" do 
    # Now just quickly do a test to make sure all the sections are there
    ensure_on 'http://databases.tangerinecentral.org/group-alex_tests/_design/ojai/index.html#assessments'
    click_button 'Assessment Name'
    click_on 'Run'

    expect(page).to have_content 'Which letter do you like most'
    click_button 'c'
    expect(page).to have_content 'Which letters do you dislike'
    click_button 'x'
    expect(page).to have_content 'Do you want to answer a third question?'
    click_button 'no'
    
    click_button 'Next'
    page.find(".start_time.time").click
    sleep 1
    click_button 'g'
    page.find(".stop_time.time").click
    click_button 'g'

    click_button 'Next'
    # page should have div with data-index='8'
    # page should have button 'save result'
    click_button "Save result"
  end

  it "should delete saved tests" do
    ensure_on 'http://databases.tangerinecentral.org/group-alex_tests/_design/ojai/index.html#assessments'
    click_on 'Assessment Name'
    page.find(".sp_assessment_delete").click
    page.find(".sp_assessment_delete_yes").click
    sleep 1
    expect(page).to have_no_content 'Assessment Name'
  end

end


