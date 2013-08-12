from Tkinter import *
import scipy.io as sio

class App:

	def __init__(self, master):

		self.params = {
		'F0_Snack': 0,
		'F0_Praat': 0,
		'F0_SHR': 0,
		'Formants_Praat': 0
		}

		frame = Frame(master, bg="white")
		frame.pack()

		w = Label(frame, text="Parameter Selection", fg="blue", bg="white", anchor=N, pady=10)
		w.pack()

		sel_all = Frame(frame, padx=5, pady=10, bd=1, bg="white")
		sel_all.pack(side=TOP)
		self.choose_all = Checkbutton(
			sel_all, text="Select All", bg="white", fg="red", anchor=S, command=self.toggle_all
			)
		self.choose_all.pack(side=BOTTOM)

		f0_options = Frame(frame, padx=5, pady=10, bd=1, bg="white")
		f0_options.pack(side=BOTTOM)
		Label(f0_options, text="F0 Algorithms", bg="white", pady=2).pack()

		self.snackpitch = Checkbutton(
			f0_options, text="F0 (Snack)", bg="white", command=self.toggle_snackpitch
			)
		self.snackpitch.pack(side=LEFT)

		self.praatpitch = Checkbutton(
			f0_options, text="F0 (Praat)", bg="white", command=self.toggle_praatpitch
			)
		self.praatpitch.pack(side=LEFT)

		self.shrpitch = Checkbutton(
			f0_options, text="F0 (SHR)", bg="white", command=self.toggle_shrpitch
			)
		self.shrpitch.pack(side=LEFT)

		formant_options = Frame(frame, padx=5, pady=10, bd=1, bg="white")
		formant_options.pack(side=BOTTOM)
		Label(formant_options, text="Formant Algorithms", bg="white", pady=2).pack()

		self.praatformants = Checkbutton(
			formant_options, text="F1, F2, F3 (Praat)", bg="white", command=self.toggle_praatformants
			)
		self.praatformants.pack()

		actions = Frame(frame, bg="white", bd=1)
		actions.pack(side=BOTTOM)

		self.button = Button(
			actions, text="Quit", fg="red", bg="white", command=frame.quit
			)
		self.button.pack(side=LEFT)

		self.printit = Button(
			actions, text="Print selection", bg="white", command=self.print_selection
			)
		self.printit.pack(side=LEFT)

		self.saveit = Button(
			actions, text="Save", fg="green", bg="white", command=self.saveit
			)
		self.saveit.pack(side=LEFT)


	def saveit(self):
		sio.savemat('param_sel.mat', {'params': self.params})

	def toggle_all(self):
		for k in self.params:
			self.params[k] = not self.params[k]

	def toggle_snackpitch(self):
		self.params['F0_Snack'] = not self.params['F0_Snack']

	def toggle_praatpitch(self):
		self.params['F0_Praat'] = not self.params['F0_Praat']

	def toggle_shrpitch(self):
		self.params['F0_SHR'] = not self.params['F0_SHR']

	def toggle_praatformants(self):
		self.params['Formants_Praat'] = not self.params['Formants_Praat']

	def print_selection(self):
		for k in self.params:
			print k, self.params[k]





root = Tk()

app = App(root)

root.mainloop()
root.destroy()