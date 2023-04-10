from argparse import RawTextHelpFormatter, ArgumentParser
import os, json, sys, math

"""
CD shortcuts: functioanlity to add and remove shortcuts to quickly reach often used directories
Usage: cdsc <shortcut> cd into file linked to shortcut
	   cdsc -n <direcetory>  <schortcut> links shortcut to directory
	   cdsc -u <shortcut> unlinks the shortcut
Implmented as a json file (.cdsc.json) linking shortcut strings to file paths
Outputs a bash command to stdout, which is evaluated by calling function
"""

FILE_PATH = "/Users/zoe/bin/.cdsc.json"

def get_sc_file(write=False):
	"""
	Returns a tuple of (opened_file, parsed_dictionary), or None if the file doesn't exist and we aren't trying to write
	If write is True and sc file does not exist, a new file is created
	write is True if we want to be able to write to the file
	"""
	if not os.path.isfile(FILE_PATH):
		if not write:
			#no shortcut file exists are defined and we are not trying to add one
			return {}
		else:
			shortcut_file = open(FILE_PATH, "w+")
	else:
		shortcut_file = open(FILE_PATH, "r+" if write else "r")

	file_content = shortcut_file.read()
	shortcut_dir = {} if len(file_content) == 0 else json.loads(file_content)
	return shortcut_file, shortcut_dir

def add_sc(shortcut, directory):
	"""
	adds a link between the shortcut and directory to the json file
	"""

	sc_file, sc_dir = get_sc_file(write=True)
	sc_dir[shortcut] =  os.path.abspath(directory)
	write_json(sc_dir, sc_file)

def get_sc(shortcut):
	"""
	returns the directory corresponding to the given shortcut
	"""

	sc_file, sc_dir = get_sc_file(write=True)
	return sc_dir.get(shortcut, None)

def list_all():
	"""
	returns a string of all the bound shortcuts and the directories they are bound to
	"""
	_, sc_dir = get_sc_file(write=True)
	if not sc_dir:
		return "There are currently no bound shortcuts"
	else:
		#create table formatting for dictionary
		len_lambda = lambda elem: len(elem)

		#maximum length of anything in sc column
		max_sc_len = len(max("shortcut", max(sc_dir.keys(), key=len_lambda), key=len_lambda))
		#define tuple # of charcters at beginning, max length of content
		sc_format = (2, max_sc_len)
		#same for dir
		max_dir_len = len(max("directory", max(sc_dir.values(), key=len_lambda), key=len_lambda))
		dir_format = (3, max_dir_len)

		tot_len = lambda frmt: math.ceil(sum(frmt)/8) * 8
		tab_number = lambda frmt, length: math.ceil((tot_len(frmt) - (frmt[0] + length)) / 8)
		tab_rp = lambda frmt, length: '\\t' * tab_number(frmt, length)

		border_str = f"+{'-' * (tot_len(sc_format))}+{'-' * (tot_len(dir_format) - 1)}+\\n"
		res_str = "\\n" + border_str
		res_str += f"| shortcut{tab_rp(sc_format, 8)} | directory{tab_rp(dir_format, 9)} |\\n"
		res_str += border_str
		for sc, directory in sc_dir.items():
			res_str += f"| {sc}{tab_rp(sc_format, len(sc))} | {directory}{tab_rp(dir_format, len(directory))} |\\n"
		return res_str + border_str


def del_sc(shortcut):
	"""
	deletes the shortcut if it's in the json file
	returns true if shortcut was deleted, false otherwise
	"""
	sc_file, sc_dir = get_sc_file(write=True)
	if shortcut in sc_dir:
		del sc_dir[shortcut]
		write_json(sc_dir, sc_file)
		return True
	else:
		return False

def write_json(my_json, file):
	"""
	helper function that writes the dictioanry my_josn to given file, overriding previous content
	"""

	file_content = json.dumps(my_json)
	file.seek(0)
	file.write(file_content)
	file.truncate()
	file.close()


parser = ArgumentParser(description='''CD Shortcuts: functioanlity to add and remove shortcuts to quickly reach often used directories
Examples: \tcdsc [shortcut] cd into file linked to shortcut
\t\tcdsc -n [directory] [shortcut] links shortcut to directory
\t\tcdsc -u [shortcut] unlinks the shortcut''', formatter_class=RawTextHelpFormatter)
parser.add_argument('shortcut', nargs='?', help='the string to be used as a shortcut to the directory')
parser.add_argument('-n', type=str, dest='directory', help='create a new link between the shortcut string and specified directory', metavar=("directory"))
parser.add_argument('-nh', dest='new_here', action='store_true', help='creates a new link between the shortcut string and the current directory')
parser.add_argument('-u', dest='unlink', action='store_true', help='unlink the specified shortcut')
parser.add_argument('-l', dest='list', action='store_true', help='lists currently linked shortcuts')


args = parser.parse_args()

if args.list:
	print(f'echo -e "{list_all()}"')
else:
	#raise error if shortcut not defined:
	if args.shortcut is None:
		parser.error("No shortcut defined")
	else:
		if args.directory is not None or args.new_here:
			# case where we are adding shortcut
			add_sc(args.shortcut, args.directory if args.directory is not None else '.')
			print(f"echo 'Succesfully linked shortcut \"{args.shortcut}\".'")
		elif args.unlink:
			# case where we are unlinking
			if del_sc(args.shortcut):
				print(f"echo 'Succesfully unlinked shortcut \"{args.shortcut}\".'")
			else:
				print(f"echo 'Shortcut \"{args.shortcut}\" is not currently linked.'")
		elif args.list:
			print(f'echo -e "{list_all()}"')
		else:
			#case where we are cding to correct directory!
			cd_dir = get_sc(args.shortcut)
			if cd_dir is not None:
				print(f"cd {get_sc(args.shortcut)}")
			else:
				print(f"echo 'Shortcut \"{args.shortcut}\" is not currently linked.'")

