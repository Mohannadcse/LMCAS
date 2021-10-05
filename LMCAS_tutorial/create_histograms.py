import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import sys

def calculatePercentChange(a, b):
    return (-100 * ((b-a)/a))

#Creating rop_report dataframe
rop_report_og = pd.read_csv(sys.argv[2])
rop_report_db = pd.read_csv(sys.argv[3])
rop_report = [rop_report_og,rop_report_db]
rop_report = pd.concat(rop_report)

rop_report = rop_report.drop(columns=['fbname'])
rop_report.reset_index(inplace=True)
rop_report = rop_report.drop(columns=['index'])
stats = pd.read_csv(sys.argv[4])
df = stats.join(rop_report)
ts = df.drop(columns=['AppName','Pass'])
ts.columns = ['IR inst','Functions', 'Basic Blocks', 'Binary Size', 'Total Gadgets','JOP', 'SYS', 'ROP']
headers = list(ts)
ts = ts.to_numpy()
percentage_change = []
for c in ts.transpose():
    percentage_change.append(calculatePercentChange(c[0],c[1]))
foo = headers[1]
headers[1] = headers[2]
headers[2] = foo


bar = percentage_change[1]
percentage_change[1] = percentage_change[2]
percentage_change[2] = bar

print("\n***************************\n")
print("Stats generated")
pd.options.mode.chained_assignment = None
df['Pass'][1] = "debloated"
print(df.to_string(index=False))

print("\n***************************\n")
print("\tPercentage Reduced\t")
i = 0
for f in percentage_change:
	if i > 0 and i < 5:
		print(headers[i]+"\t\t"+str(round(f,2)))
	else:
		print(headers[i]+"\t\t\t"+str(round(f,2)))
	i = i + 1
print("\n***************************\n")


x = np.arange(len(headers))
width = 0.35
fig, ax = plt.subplots()
rects = ax.bar(x,percentage_change,width)
ax.set_ylabel('Reduction Rate')
ax.set_title('How Effective was the debloating?')
ax.set_xticks(x)
ax.set_xticklabels(headers)
#ax.bar_label(rects,padding=3)
plt.tick_params(axis='x', which='major', labelsize=7)
plt.setp(ax.get_xticklabels(), rotation=15, horizontalalignment='right')
plt.show()
plt.savefig(sys.argv[1] + '_reductions.png')
