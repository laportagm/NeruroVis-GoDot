extends SceneTree

class_name TestRunnerCLI

var test_results = []
var total_tests = 0
var passed_tests = 0
var failed_tests = 0
var start_time = 0

func _init():
	print("🧪 NeuroVis CI Test Runner Starting...")
	start_time = Time.get_ticks_msec()
	
	run_all_tests()
	
	generate_reports()
	quit()

func run_all_tests():
	print("📋 Discovering test files...")
	
	var test_files = discover_test_files()
	total_tests = test_files.size()
	
	if total_tests == 0:
		print("❌ No test files found!")
		return
	
	print("🔍 Found %d test files" % total_tests)
	
	for test_file in test_files:
		run_test_file(test_file)

func discover_test_files() -> Array[String]:
	var test_files: Array[String] = []
	var test_dirs = ["tests/", "tests/unit/", "tests/integration/"]
	
	for test_dir in test_dirs:
		if DirAccess.dir_exists_absolute("res://" + test_dir):
			var dir = DirAccess.open("res://" + test_dir)
			if dir:
				dir.list_dir_begin()
				var file_name = dir.get_next()
				while file_name != "":
					if file_name.ends_with("_test.gd") or file_name.ends_with("Test.gd"):
						test_files.append(test_dir + file_name)
					file_name = dir.get_next()
	
	return test_files

func run_test_file(test_file_path: String):
	print("🧪 Running: %s" % test_file_path)
	
	var script = load("res://" + test_file_path)
	if script == null:
		record_test_failure(test_file_path, "Failed to load test script")
		return
	
	var test_instance = script.new()
	if test_instance == null:
		record_test_failure(test_file_path, "Failed to instantiate test")
		return
	
	var test_start_time = Time.get_ticks_msec()
	
	if test_instance.has_method("run_test"):
		var result = test_instance.run_test()
		var test_duration = Time.get_ticks_msec() - test_start_time
		
		if result == true:
			record_test_success(test_file_path, test_duration)
		else:
			record_test_failure(test_file_path, "Test returned false", test_duration)
	else:
		record_test_failure(test_file_path, "No run_test method found")
	
	test_instance.queue_free()

func record_test_success(test_name: String, duration_ms: int = 0):
	passed_tests += 1
	test_results.append({
		"name": test_name,
		"status": "PASS",
		"duration": duration_ms,
		"message": ""
	})
	print("✅ PASS: %s (%dms)" % [test_name, duration_ms])

func record_test_failure(test_name: String, error_message: String, duration_ms: int = 0):
	failed_tests += 1
	test_results.append({
		"name": test_name,
		"status": "FAIL",
		"duration": duration_ms,
		"message": error_message
	})
	print("❌ FAIL: %s - %s" % [test_name, error_message])

func generate_reports():
	var total_duration = Time.get_ticks_msec() - start_time
	
	print("\n📊 Test Summary:")
	print("================")
	print("Total Tests: %d" % total_tests)
	print("Passed: %d" % passed_tests)
	print("Failed: %d" % failed_tests)
	print("Duration: %dms" % total_duration)
	print("Success Rate: %.1f%%" % (float(passed_tests) / float(total_tests) * 100.0 if total_tests > 0 else 0.0))
	
	generate_junit_xml()
	generate_coverage_json()

func generate_junit_xml():
	var xml_content = """<?xml version="1.0" encoding="UTF-8"?>
<testsuites>
  <testsuite name="NeuroVis Tests" tests="%d" failures="%d" time="%.3f">
""" % [total_tests, failed_tests, (Time.get_ticks_msec() - start_time) / 1000.0]
	
	for result in test_results:
		xml_content += """    <testcase name="%s" time="%.3f">
""" % [result.name, result.duration / 1000.0]
		
		if result.status == "FAIL":
			xml_content += """      <failure message="%s" />
""" % result.message
		
		xml_content += """    </testcase>
"""
	
	xml_content += """  </testsuite>
</testsuites>"""
	
	var file = FileAccess.open("test-results.xml", FileAccess.WRITE)
	if file:
		file.store_string(xml_content)
		file.close()
		print("📄 Generated: test-results.xml")

func generate_coverage_json():
	var coverage_data = {
		"timestamp": Time.get_datetime_string_from_system(),
		"total_tests": total_tests,
		"passed_tests": passed_tests,
		"failed_tests": failed_tests,
		"success_rate": float(passed_tests) / float(total_tests) * 100.0 if total_tests > 0 else 0.0,
		"duration_ms": Time.get_ticks_msec() - start_time,
		"test_results": test_results
	}
	
	var file = FileAccess.open("test-coverage.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(coverage_data))
		file.close()
		print("📄 Generated: test-coverage.json")