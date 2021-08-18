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
ts.columns = ['Instructions','Functions', 'Basic Blocks', 'Size', 'Dangerous Instructions','JOP Instructions', 'SYS instructions', 'ROP instructions']
headers = list(ts)
ts = ts.to_numpy()
percentage_change = []
for c in ts.transpose():
    percentage_change.append(calculatePercentChange(c[0],c[1]))

print(headers)
print(percentage_change)
print(df)

x = np.arange(len(headers))
width = 0.35
fig, ax = plt.subplots()
rects = ax.bar(x,percentage_change,width)
ax.set_ylabel('Reduction Rate')
ax.set_title('How Effective was the debloating?')
ax.set_xticks(x)
ax.set_xticklabels(headers)
ax.bar_label(rects,padding=3)
plt.tick_params(axis='x', which='major', labelsize=7)
plt.setp(ax.get_xticklabels(), rotation=15, horizontalalignment='right')
plt.show()
plt.savefig(sys.argv[1] + '_reductions.png')
