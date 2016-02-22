<% ui.includeJavascript("laboratoryapp", "jQuery.print.js") %>

<script>
    
	
    jq(function(){
        jq('#date').datepicker("option", "dateFormat", "dd/mm/yy");

        
		
    });
	
    var editResultsDialog,
		editResultsForm,
		editResultsParameterOpts = { editResultsParameterOptions : ko.observableArray([]) };

    jq(function(){
        ko.applyBindings(editResultsParameterOpts, jq("#edit-result-form")[0]);

        editResultsDialog = jq("#edit-result-form").dialog({
            autoOpen: false,
            modal: true,
            width: 350,
            buttons: {
                Save: saveEditResult,
                Cancel: function() {
                    editResultsDialog.dialog( "close" );
                }
            },
            close: function() {
                editResultsForm[0].reset();
            }
        });

        editResultsForm = editResultsDialog.find( "form" ).on( "submit", function( event ) {
            event.preventDefault();
            saveEditResult();
        });
    });

    function showEditResultForm(testId) {
        getEditResultTempLate(testId);
        editResultsForm.find("#edit-result-id").val(testId);
        editResultsDialog.dialog( "open" );
    }

    function getEditResultTempLate(testId) {
        jq.getJSON('${ui.actionLink("laboratoryapp", "result", "getResultTemplate")}',
                { "testId" : testId }
        ).success(function(editResultsParameterOptions){
                    editResultsParameterOpts.editResultsParameterOptions.removeAll();
                    var details = ko.utils.arrayFirst(result.items(), function(item) {
                        return item.testId == testId;
                    });
                    jq.each(editResultsParameterOptions, function(index, editResultsParameterOption) {
                        editResultsParameterOption['patientName'] = details.patientName;
                        editResultsParameterOption['testName'] = details.test.name;
                        editResultsParameterOption['startDate'] = details.startDate;
                        editResultsParameterOpts.editResultsParameterOptions.push(editResultsParameterOption);
                    });
                });
    }

    function saveEditResult(){
        var dataString = editResultsForm.serialize();
        jq.ajax({
            type: "POST",
            url: '${ui.actionLink("laboratoryapp", "result", "saveResult")}',
            data: dataString,
            dataType: "json",
            success: function(data) {
                if (data.status === "success") {
                    jq().toastmessage('showNoticeToast', data.message);
                    editResultsDialog.dialog("close");
                }
            }
        });
    }

    function loadPatientReport(patientId){
        console.log(editResultsDate);
        queryparamenters = "?patientId=" + patientId + '&selectedDate=' + editResultsDate;
        window.location.replace('${ui.pageLink("laboratoryapp", "patientReport")}'+queryparamenters);
    }
    function Result() {
        self = this;
        self.items = ko.observableArray([]);
    }
    var result = new Result();

    jq(function(){
        ko.applyBindings(result, jq("#test-results")[0]);
    });
</script>

<div>
    <form>
        <fieldset>
			<div class="onerow">
				<div class="col4">
					<label for="accepted-date-edit-display">Date </label>
				</div>
				
				<div class="col4">
					<label for="search-results-for">Patient Identifier/Name</label>
				</div>
				
				<div class="col4 last">
					<label for="investigation-results">Investigation</label>
				</div>
			</div>
			
			<div class="onerow">
				<div class="col4">
					${ui.includeFragment("uicommons", "field/datetimepicker", [id: 'accepted-date-edit', label: 'Date', formFieldName: 'acceptedDate', useTime: false, defaultToday: true])}
				</div>
				
				<div class="col4">
					<input id="search-results-for"/>
				</div>
				
				<div class="col4 last">
					<select name="investigation" id="investigation-results">
						<option value="0">Select an investigation</option>
						<% investigations.each { investigation -> %>
						<option value="${investigation.id}">${investigation.name.name}</option>
						<% } %>
					</select>
				</div>
			</div>
			
            <br/>
            <br/>
        </fieldset>
    </form>
</div>

<table id="test-results">
    <thead>
    <th>Sample ID</th>
    <th>Date</th>
    <th>Patient ID</th>
    <th>Name</th>
    <th>Gender</th>
    <th>Age</th>
    <th>Test</th>
    <th>Results</th>
    <th>Reports</th>
    </thead>
    <tbody data-bind="foreach: items">
    <td data-bind="text: sampleId"></td>
    <td data-bind="text: startDate"></td>
    <td data-bind="text: patientIdentifier"></td>
    <td data-bind="text: patientName"></td>
    <td data-bind="text: gender"></td>
    <td>
        <span data-bind="if: age < 1">Less than 1 year</span>
        <!-- ko if: age > 1 -->
        <span data-bind="value: age"></span>
        <!-- /ko -->
    </td>
    <td data-bind="text: test.name"></td>
    <td>
        <a data-bind="attr: { href : 'javascript:showEditResultForm(' + testId + ')' }">Edit Result</a>
    </td>
    <td>
        <a data-bind="attr: { href : 'javascript:loadPatientReport(' + patientId + ')' }">Report</a>
    </td>
    </tbody>
</table>

<div id="edit-result-form" title="Results">
    <form>
        <fieldset>
            <input type="hidden" name="wrap.testId" id="edit-result-id" />
            <div data-bind="foreach: editResultsParameterOptions">
                <input type="hidden" data-bind="attr: { 'name' : 'wrap.results[' + \$index() + '].conceptName' }, value: title" >
                <p data-bind="text: 'Patient Name: ' + patientName"></p>
                <p data-bind="text: 'Test: ' + testName"></p>
                <p data-bind="text: 'Date: ' + startDate"></p>
                <div data-bind="if: type && type.toLowerCase() === 'select'">
                    <label for="resultr-option" class="input-position-class left" data-bind="text: title"></label>
                    <select id="resultr-option"
                            data-bind="attr : { 'name' : 'wrap.results[' + \$index() + '].selectedOption' },
							foreach: options">
                        <option data-bind="attr: { name : value, selected : (\$parent.defaultValue === value) }, text: label"></option>
                    </select>
                </div>

                <div data-bind="if: !type">
                    <label for="result-text" data-bind="text: title"></label>
                    <input id="result-text" class="result-text" type="text" data-bind="attr : { 'name' : 'wrap.results[' + \$index() + '].value' }" >
                </div>
                <div data-bind="if: type && type.toLowerCase() !== 'select'">
                    <p class="margin-left left">
                        <label for="result-text" data-bind="text: title"></label>
                        <input class="result-text" data-bind="attr : { 'type' : type, 'name' : 'wrap.results[' + \$index() + '].value', value : defaultValue }" >
                    </p>
                </div>
            </div>
        </fieldset>
    </form>
</div>


