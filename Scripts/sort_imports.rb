#encoding: utf-8

require 'pathname'

def create_regex(regex)
	/^(?:#ifdef.*)*?(#{regex})\s*?(?:#endif)*?\s*?$/m
end

def sorted_from_regex(file, regex)
	imports = []
	matches = []
	
	file.scan(regex) do |match|
		match_data = Regexp.last_match
		matches.push match_data
		imports.push [match_data.to_s, match.first].map(&:strip)
	end
	imports.sort_by! { |a| a[1].downcase }.map! { |a| a.first }
	imports.uniq!
	
	[imports, matches]
end

def sorted_modules(file)
	module_import_regex = create_regex("\@import .*?")
	sorted_from_regex(file, module_import_regex)
end

def sorted_lib_imports(file)
	lib_import_regex = create_regex("\#import <.*?$")
	sorted_from_regex(file, lib_import_regex)
end

def sorted_regular_imports(file, file_name)
	import_regex = create_regex('#import \".*?$')
	imports, matches = sorted_from_regex(file, import_regex)

	if file_name.end_with? ".m"
		header_parts = file_name.split(File::SEPARATOR).last.split('.')
		header_parts[-1] = 'h'
		header_name = header_parts.join '.'

		import_str = "\#import \"#{header_name}\""
		idx = imports.index import_str
		if idx
			import = imports.delete_at idx
			imports.unshift import
		end
	end
	
	[imports, matches]
end

ARGV.each do |a|
	text = File.read(a)
	
	next if text.include? "// disable_import_sort"
	original_text = text.dup

	file_name = File.basename(Pathname a)
	modules, modules_matches = sorted_modules text
	libs, libs_matches = sorted_lib_imports text
	regular, regular_matches = sorted_regular_imports(text, file_name)
	
	all_matches = [modules_matches, libs_matches, regular_matches].flatten

	if all_matches.length > 0
		formatted_output = [modules, libs, regular].reject(&:empty?).map { |a| a.join "\n" }.join "\n\n"
		start = all_matches.map { |m| m.begin(0) }.min
		last  = all_matches.map { |m| m.end(0) }.max
		length = last - start
		
		text[start, length] = formatted_output
		if original_text != text
		  File.open(a, "w") { |file| file.puts text }
		end
	end
end
