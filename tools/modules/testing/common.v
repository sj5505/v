module testing

import (
	os
	term
	benchmark
	filepath
	time
	runtime
)

pub struct TestSession {
pub mut:
	files []string
	vexe string
	vargs string
	failed bool
	benchmark benchmark.Benchmark

	ok string
	fail string
mut:
	show_stats bool
	done int atomic
	idx int atomic
}

pub fn new_test_session(vargs string) TestSession {
	return TestSession{
		vexe: vexe_path()
		vargs: vargs
	}
}

pub fn vexe_path() string {
	// NB: tools extracted from v require that the first
	// argument to them to be the v executable location.
	// They are usually launched by vlib/compiler/vtools.v,
	// launch_tool/1 , which provides it.
	return os.args[1]
}


pub fn (ts mut TestSession) init() {
	ts.ok   = term.ok_message('OK')
	ts.fail = term.fail_message('FAIL')
	ts.benchmark = benchmark.new_benchmark()
}

pub fn (ts mut TestSession) test_file(relative_file string) {
	//ts.done++
	file := os.realpath( relative_file )
	$if windows {
		if file.contains('sqlite') { return }
	}
	$if !macos {
		if file.contains('customer') { return }
	}
	$if msvc {
		if file.contains('asm') { return }
	}
	$if tinyc {
		if file.contains('asm') { return }
	}
	tmpc_filepath := file.replace('.v', '.tmp.c')

	cmd := '"$ts.vexe" $ts.vargs "$file"'
	//eprintln('>>> v cmd: $cmd')

	ts.benchmark.step()
	if ts.show_stats {
		eprintln('-------------------------------------------------')
		status := os.system(cmd)
		if status == 0 {
			ts.benchmark.ok()
		}else{
			ts.benchmark.fail()
			ts.failed = true
			//ts.done--
			return
		}
	}else{
		r := os.exec(cmd) or {
			ts.benchmark.fail()
			ts.failed = true
			eprintln(ts.benchmark.step_message('$relative_file ${ts.fail}'))
			//ts.done--
			return
		}
		if r.exit_code != 0 {
			ts.benchmark.fail()
			ts.failed = true
			eprintln(ts.benchmark.step_message('$relative_file ${ts.fail}\n`$file`\n (\n$r.output\n)'))
		} else {
			ts.benchmark.ok()
			eprintln(ts.benchmark.step_message('$relative_file ${ts.ok}'))
		}
	}
	os.rm( tmpc_filepath )
	//ts.done--
}

pub fn (ts mut TestSession) test() {
	nr_cpus := runtime.nr_cpus()
	println("Parallel test, nr_cpus=$nr_cpus")
	ts.init()
	ts.show_stats = '-stats' in ts.vargs.split(' ')
	ts.done = nr_cpus
	for _ in 0..nr_cpus {
		go ts.test_worker()
	}
	// Wait for all workers to finish
	for {
		time.sleep(3)
		if ts.done == 0 {
			println('breaking')
			break
		}
	}
}

fn (ts mut TestSession) test_worker() {
	//for dot_relative_file in ts.files {
	for {
		if ts.idx >= ts.files.len {
			break
		}
		dot_relative_file := ts.files[ts.idx]
		ts.idx++
		relative_file := dot_relative_file.replace('./', '')
		ts.test_file(relative_file)
	}
	ts.done--
}

pub fn vlib_should_be_present( parent_dir string ) {
	vlib_dir := filepath.join( parent_dir, 'vlib' )
	if !os.is_dir( vlib_dir ){
		eprintln('$vlib_dir is missing, it must be next to the V executable')
		exit(1)
	}
}

pub fn v_build_failing(zargs string, folder string) bool {
	main_label := 'Building $folder ...'
	finish_label := 'building $folder'
	vexe := vexe_path()
	parent_dir := os.dir(vexe)
	vlib_should_be_present( parent_dir )
	vargs := zargs.replace(vexe, '')

	eprintln(main_label)
	eprintln('   v compiler args: "$vargs"')

	mut session := new_test_session( vargs )
	files := os.walk_ext(filepath.join(parent_dir, folder),'.v')
	mains := files.filter(!it.contains('modules'))
	mut rebuildable_mains := mains
	if os.user_os() == 'windows' {
		// on windows, an executable can not be rebuilt, while it is running
		myself := os.executable().replace('.exe', '') + '.v'
		mains_without_myself := mains.filter(!it.contains(myself))
		rebuildable_mains = mains_without_myself // workaround a bug in it.contains generation
	}
	session.files << rebuildable_mains
	session.test()
	eprintln( session.benchmark.total_message( finish_label ) )

	return session.failed
}

pub fn build_v_cmd_failed (cmd string) bool {
	res := os.exec(cmd) or {
		return true
	}
	if res.exit_code != 0 {
		eprintln('')
		eprintln( res.output )
		return true
	}
	return false
}

pub fn building_any_v_binaries_failed() bool {
	eprintln('Building V binaries...')
	eprintln('VFLAGS is: "' + os.getenv('VFLAGS') + '"')
	vexe := testing.vexe_path()
	parent_dir := os.dir(vexe)
	testing.vlib_should_be_present( parent_dir )
	os.chdir( parent_dir )

	mut failed := false
	v_build_commands := [
		'$vexe -o v_g             -g  v.v',
		'$vexe -o v_prod_g  -prod -g  v.v',
		'$vexe -o v_cg            -cg v.v',
		'$vexe -o v_prod_cg -prod -cg v.v',
		'$vexe -o v_prod    -prod     v.v',
	]

	mut bmark := benchmark.new_benchmark()
	bok   := term.ok_message('OK')
	bfail := term.fail_message('FAIL')
	for cmd in v_build_commands {
		bmark.step()
		if build_v_cmd_failed(cmd) {
			bmark.fail()
			failed = true
			eprintln(bmark.step_message('$cmd => ${bfail} . See details above ^^^^^^^'))
			eprintln('')
			continue
		}
		bmark.ok()
		eprintln(bmark.step_message('$cmd => ${bok}'))
	}
	bmark.stop()
	eprintln( bmark.total_message( 'building v binaries' ) )

	return failed
}
