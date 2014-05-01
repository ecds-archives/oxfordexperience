from django import forms

class DocSearchForm(forms.Form):
    "Search documentations by keyword/title/author/date"
    keyword = forms.CharField(required=False)
    title = forms.CharField(required=False)
    author = forms.CharField(required=False)
    date = forms.CharField(required=False)

    def clean(self):
        """Custom form validation."""
        cleaned_data = self.cleaned_data

        keyword = cleaned_data.get('keyword')
        title = cleaned_data.get('title')
        author = cleaned_data.get('author')
        date = cleaned_data.get('date')
 
       # raise forms.ValidationError("Date invalid")
       
        #Validate at least one term has been entered
        #if not title and not author and not keyword and not date:
        if not author and not title and not keyword and not date:
            del cleaned_data['author']
            del cleaned_data['title']
            del cleaned_data['keyword']
            del cleaned_data['date']
            raise forms.ValidationError("Please enter search terms.")
    
        return cleaned_data
