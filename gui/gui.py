from Tkinter import *
import scipy.io as sio

class App:

	def __init__(self, master):

		fields = ["F0", "Formants"]

		self.params = {
		'F0_Snack': 0,
		'F0_Praat': 0,
		'F0_SHR': 0,
		'Formants_Praat': 0
		}


		labelfont = ('helvetica', '14', 'bold')
		sublabelfont = ('helvetica', '12', 'bold')
		checkfont = ('helvetica', '9')

		mainlabel = Label(master, text='Parameter Selection')
		mainlabel.config(bg='white', fg='black', font=labelfont, height=3, width=20)
		mainlabel.pack(expand=YES, fill=BOTH)

		# FIXME: need to disable other checkboxes when this one is selected
		select_all = Checkbutton(master, text="Choose all", command=self.toggle_all)
		select_all.config(fg="red", bg="white", font=checkfont, height=3, width=10)
		select_all.pack(expand=YES, fill=BOTH)

		f0_options = Frame(master)
		f0_options.config(bg="white")
		f0_options.pack(expand=YES, fill=BOTH)
		f0_label = Label(f0_options, text="F0 Algorithms")
		f0_label.config(bg='white', fg='black', font=sublabelfont, height=3, width=20)
		f0_label.pack(expand=YES, fill=BOTH)


		self.snackpitch = Checkbutton(
			f0_options, text="F0 (Snack)", bg="white", font=checkfont, command=self.toggle_snackpitch
			)
		self.snackpitch.pack(side=LEFT)

		self.praatpitch = Checkbutton(
			f0_options, text="F0 (Praat)", bg="white", font=checkfont, command=self.toggle_praatpitch
			)
		self.praatpitch.pack(side=LEFT)

		self.shrpitch = Checkbutton(
			f0_options, text="F0 (SHR)", bg="white", font=checkfont, command=self.toggle_shrpitch
			)
		self.shrpitch.pack(side=LEFT)

		formant_options = Frame(master)
		formant_options.config(bg="white")
		formant_options.pack(expand=YES, fill=BOTH)
		formant_label = Label(formant_options, text="Formant Algorithms")
		formant_label.config(bg="white", fg="black", font=sublabelfont, height=3, width=20)
		formant_label.pack(expand=YES, fill=BOTH)


		self.praatformants = Checkbutton(
			formant_options, text="F1, F2, F3 (Praat)", bg="white", font=checkfont, command=self.toggle_praatformants
			)
		self.praatformants.pack(expand=YES, fill=BOTH)


		actions = Frame(master)
		actions.config(bg="white", pady=10)
		actions.pack(expand=YES, fill=BOTH)

		self.button = Button(
			actions, text="Quit", fg="red", bg="white", command=actions.quit
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