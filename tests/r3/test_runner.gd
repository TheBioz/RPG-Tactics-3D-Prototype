extends SceneTree
## Headless runner for the isolated R3 scheduler-domain suite.

const SchedulerTestsScript = preload("res://tests/r3/test_scheduler.gd")

func _initialize() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	var tests: RefCounted = SchedulerTestsScript.new()
	var summary: Dictionary = tests.run()
	var checks: int = int(summary.get("checks", 0))
	var failures: PackedStringArray = summary.get("failures", PackedStringArray())
	if failures.is_empty():
		print("R3-C1 SWRR scheduler: %d checks passed" % checks)
		quit(0)
		return
	for failure in failures:
		push_error("R3-C1: " + str(failure))
	push_error("R3-C1 SWRR scheduler: %d checks, %d failures" % [checks, failures.size()])
	quit(1)
