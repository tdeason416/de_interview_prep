-- You are managing a task scheduling system where each task has a specific start and end time. Multiple tasks can run simultaneously if there are enough CPUs available, but each CPU can only run one task at a time.
-- Given a list of task execution intervals, determine the minimum number of CPUs required to execute all tasks without any conflicts. When processing the data, duplicate task entries should only be counted once, and tasks with missing start or end times should be excluded from the calculation. Tasks without names can still be included as long as they have valid execution times. Note that when a task ends at the exact moment another task starts, they do not conflict since the CPU can be reused immediately.
-- Return the minimum number of CPUs required.

-- TABLE DESCRIPTION
-- end_time: timestamp without time zone
-- start_time: timestamp without time zone
-- task_id: bigint
-- task_name: text