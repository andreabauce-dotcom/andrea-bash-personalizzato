# shellcheck shell=bash
#
# Functions for measuring and reporting how long a command takes to run.

# Notice: This function used to run as a sub-shell while defining:
# local LC_ALL=C
#
# DFARREL You would think LC_NUMERIC would do it, but not working in my local.
# Note: LC_ALL='en_US.UTF-8' has been used to enforce the decimal point to be
# a period, but the specific locale 'en_US.UTF-8' is not ensured to exist in
# the system.  One should instead use the locale 'C', which is ensured by the
# C and POSIX standards.
#
# We now use EPOCHREALTIME, while replacing any non-digit character by a period.
#
# Technically, one can define a locale with decimal_point being an arbitrary string.
# For example, ps_AF uses U+066B as the decimal point.
#
# cf: https://github.com/Bash-it/bash-it/pull/2366#discussion_r2760681820
#
# Get shell duration in decimal format regardless of runtime locale.
function _command_duration_current_time() {
	local current_time
	if [[ -n "${EPOCHREALTIME:-}" ]]; then
		current_time="${EPOCHREALTIME//[!0-9]/.}"
	else
		current_time="$SECONDS"
	fi

	echo "$current_time"
}

: "${COMMAND_DURATION_START_SECONDS:=$(_command_duration_current_time)}"
: "${COMMAND_DURATION_ICON:=🕘}"
: "${COMMAND_DURATION_MIN_SECONDS:=1}"
: "${COMMAND_DURATION_PRECISION:=1}"

function _command_duration_pre_exec() {
	COMMAND_DURATION_START_SECONDS="$(_command_duration_current_time)"
}

function _command_duration_pre_cmd() {
	COMMAND_DURATION_START_SECONDS=""
}

function _dynamic_clock_icon {
	local clock_hand duration="$1"

	# Clock only work for time >= 1s
	if ((duration < 1)); then
		duration=1
	fi

	# clock hand value is between 90 and 9b in hexadecimal.
	# so between 144 and 155 in base 10.
	printf -v clock_hand '%x' $((((${duration:-${SECONDS}} - 1) % 12) + 144))
	printf -v 'COMMAND_DURATION_ICON' '%b' "\xf0\x9f\x95\x$clock_hand"
}

function _command_duration() {
	[[ -n "${BASH_IT_COMMAND_DURATION:-}" ]] || return
	[[ -n "${COMMAND_DURATION_START_SECONDS:-}" ]] || return

	local current_time
	current_time="$(_command_duration_current_time)"

	local -i command_duration=0
	local -i minutes=0 seconds=0
	local microseconds=""

	local -i command_start_seconds=${COMMAND_DURATION_START_SECONDS%.*}
	local -i current_time_seconds=${current_time%.*}

	# Calculate seconds difference
	command_duration=$((current_time_seconds - command_start_seconds))

	# Calculate microseconds if both timestamps have fractional parts
	if [[ "$COMMAND_DURATION_START_SECONDS" == *.* ]] && [[ "$current_time" == *.* ]] && ((COMMAND_DURATION_PRECISION > 0)); then
		local -i command_start_microseconds=$((10#${COMMAND_DURATION_START_SECONDS##*.}))
		local -i current_time_microseconds=$((10#${current_time##*.}))

		if ((current_time_microseconds >= command_start_microseconds)); then
			microseconds=$((current_time_microseconds - command_start_microseconds))
		else
			((command_duration -= 1))
			microseconds=$((1000000 + current_time_microseconds - command_start_microseconds))
		fi

		# Pad with leading zeros to 6 digits, then take first N digits
		printf -v microseconds '%06d' "$microseconds"
		microseconds="${microseconds:0:$COMMAND_DURATION_PRECISION}"
	fi

	if ((command_duration >= COMMAND_DURATION_MIN_SECONDS)); then
		minutes=$((command_duration / 60))
		seconds=$((command_duration % 60))

		_dynamic_clock_icon "${command_duration}"
		if ((minutes > 0)); then
			printf "%s %s%dm %ds" "${COMMAND_DURATION_ICON:-}" "${COMMAND_DURATION_COLOR:-}" "$minutes" "$seconds"
		else
			printf "%s %s%ss" "${COMMAND_DURATION_ICON:-}" "${COMMAND_DURATION_COLOR:-}" "$seconds${microseconds:+.$microseconds}"
		fi
	fi
}

_bash_it_library_finalize_hook+=("safe_append_preexec '_command_duration_pre_exec'")
_bash_it_library_finalize_hook+=("safe_append_prompt_command '_command_duration_pre_cmd'")
