"""
Scrape a GitHub profile and get a list of repositories and their
descriptions, using the requests and BeautifulSoup4 libraries.

2025-01-22 | CR

Requirements:
    pip install requests beautifulsoup4
"""
import random
import string

DEBUG = True


def log_debug(message):
    if DEBUG:
        print(message)


def get_github_base_url(username) -> str:
    url = f"https://github.com/{username}"
    if username.startswith("https://github.com/"):
        url = username
    # log_debug(f"USERNAME: {username} | URL: {url}")
    return url


def get_html_element(soup, selector, value=None, attrs=None):
    try:
        if value is not None:
            element = soup.find(selector, value)
        elif attrs is not None:
            element = soup.find(selector, attrs=attrs)
        else:
            element = soup.find(selector)
        if element is None:
            return None
        return element.text.strip()
    except Exception as e:
        log_debug(f"ERROR-GHE-10: {e}")
        return None


def scrape_github_profile_with_requests(username):
    """
    Scrapes a GitHub profile to extract the main information
    (name, bio, company, location, website, social accounts, README).

    Args:
        username (str): The GitHub username.

    Returns:
        dict: A dictionary where keys are name, bio, company, location,
        website, social accounts, readme.
        Returns an empty dictionary if the profile is not found or an error
        occurs.
    """
    try:
        url = get_github_base_url(username)
        response = requests.get(url)
        response.raise_for_status()  # Raise an exception for bad status codes

    except requests.exceptions.RequestException as e:
        print(f"ERROR-SGP-10: Request Error: {e}")
        return {}
    except Exception as e:
        print(f"ERROR-SGP-20: An error occurred: {e}")
        return {}

    log_debug(f"\nURL: {url} | Status Code: {response.status_code}\n")
    return scrape_github_profile(response.content, url)


def scrape_github_profile(response_content, url=None, no_pii=False):
    """
    Scrapes a GitHub profile to extract the main information
    (name, bio, company, location, website, social accounts, README).

    Args:
        response_content (str): The GitHub profile html content.

    Returns:
        dict: A dictionary where keys are name, bio, company, location,
        website, social accounts, readme.
        Returns an empty dictionary if the profile is not found or an error
        occurs.
    """
    profile = {}
    try:
        # log_debug(f"01-Response.content:\n{response_content}\n\n")

        # Parse the HTML content
        soup = BeautifulSoup(response_content, 'html.parser')

        # Get the main information
        name_element = soup.find('h1', {'class': "vcard-names"})
        name = get_html_element(
            name_element if name_element else soup,
            'span',
            attrs={'itemprop': "name"})
        nickname = get_html_element(
            name_element if name_element else soup,
            'span',
            attrs={'itemprop': "additionalName"})
        bio = get_html_element(
            soup if name_element else soup,
            'div',
            {
                'class': 'p-note user-profile-bio mb-3 js-user-profile-bio f4'
            })
        company = get_html_element(
            soup if name_element else soup,
            'li',
            attrs={'itemprop': "worksFor"})
        location = get_html_element(
            soup if name_element else soup,
            'li',
            attrs={'itemprop': "homeLocation"})
        website = get_html_element(soup, 'li', attrs={'itemprop': "url"})
        social_accounts = [
            {
                link.find('title').text.strip(): link.find('a')['href']
                if link.find('a') else None
            }
            for link in soup.find_all('li', attrs={'itemprop': 'social'})
        ]
        readme = get_html_element(soup, 'article', attrs={'itemprop': 'text'})
        # Log the scraped data

        # Tokenize PII
        if no_pii:
            no_pii_name = nickname or \
                ''.join(random.choices(string.ascii_letters +
                        string.digits, k=10))
            bio = bio.replace(name, no_pii_name)
            readme = readme.replace(name, no_pii_name)
        profile = {
            "name": no_pii_name if no_pii else name,
            "nickname": nickname,
            "bio": bio,
            "company": company,
            "location": location,
            "website": website,
            "social_accounts": social_accounts,
            "readme": readme,
            "url": url
        }

    except Exception as e:
        print(f"ERROR-SGP-30: An error occurred: {e}")
        # raise
        return {}

    return profile


def scrape_github_repos_with_requests(username):
    """
    Scrapes a GitHub profile to extract repository names and descriptions.

    Args:
        username (str): The GitHub username.

    Returns:
        dict: A dictionary where keys are repository names and values are
        their descriptions. Returns an empty dictionary if the profile is
        not found or an error occurs.
    """
    base_url = get_github_base_url(username)
    try:
        url = f"{base_url}?tab=repositories"
        response = requests.get(url)
        response.raise_for_status()  # Raise an exception for bad status codes

    except requests.exceptions.RequestException as e:
        print(f"ERROR-SGR-10: Request Error: {e}")
        return {}
    except Exception as e:
        print(f"ERROR-SGR-20: An error occurred: {e}")
        return {}

    log_debug(f"\nURL: {url} | Status Code: {response.status_code}\n")
    return scrape_github_repos(response.content, base_url)


def scrape_github_repos(response_content, url=None):
    """
    Scrapes a GitHub profile to extract repository names and descriptions.

    Args:
        response_content (str): The GitHub repos html content.

    Returns:
        dict: A dictionary where keys are repository names and values are
        their descriptions. Returns an empty dictionary if the profile is
        not found or an error occurs.
    """
    repos = {}
    try:
        # log_debug(f"02-Response.content:\n{response_content}\n\n")

        soup = BeautifulSoup(response_content, 'html.parser')

        repo_list = soup.find_all(
            'li',
            class_='col-12 d-flex flex-justify-between width-full py-4'
                   ' border-bottom color-border-muted public source')
        for repo_item in repo_list:
            repo_name_element = repo_item.find('a', attrs={
                'itemprop': 'name codeRepository'})
            if repo_name_element:
                # Get repo name
                repo_name = repo_name_element.text.strip()
                # Get description
                description_element = repo_item.find(
                    'p',
                    attrs={'itemprop': "description"})
                if description_element:
                    description = description_element.text.strip()
                else:
                    description = 'No description available.'
                # Get topics
                topics = repo_item.find_all('a', attrs={
                    'data-octo-click': "topic_click"})
                topic_list = []
                for topic in topics:
                    topic_name = topic.text.strip()
                    topic_list.append(topic_name)
                # Build repo entry
                repos[repo_name] = {
                    'url': f"{url}/{repo_name}" if url else None,
                    'description': description,
                    'topics': topic_list
                }

    except Exception as e:
        print(f"ERROR-SGR-30: An error occurred: {e}")
        return {}

    return repos


def print_github_profile_data(profile, repo_data):
    """
    """
    if profile:
        print(f"Name: {profile['name']}")
        print(f"Nickname: {profile['nickname']}")
        print(f"Bio: {profile['bio']}")
        print(f"Company: {profile['company']}")
        print(f"Location: {profile['location']}")
        print(f"Website: {profile['website']}")
        print(f"Social Accounts: {profile['social_accounts']}")
        print(f"Readme: {profile['readme']}\n")
    else:
        print("Could not retrieve profile. Please check the username " +
              "and internet connection, or that the profile is public.")

    if repo_data:
        i = 0
        for repo_name, data in repo_data.items():
            i += 1
            print(f"{i}) Repository: {repo_name}")
            print(f"URL: {data['url']}")
            print(f"Description: {data['description']}")
            print(f"Topics: {', '.join(data['topics'])}\n")
    else:
        print("Could not retrieve repositories. Please check the username " +
              "and internet connection, or that the profile has public repos.")


def print_github_profile_data_from_url(username):
    """
    """
    profile = scrape_github_profile(username)
    repo_data = scrape_github_repos(username)
    print_github_profile_data(profile, repo_data)


def get_github_profile_data_from_html(profile_content, repos_content,
                                      domain, no_pii):
    """
    """
    profile = scrape_github_profile(profile_content, domain, no_pii)
    repo_data = scrape_github_repos(repos_content,
                                    f"{domain}?tab=repositories")
    return [{
        'profile': profile,
        'repos': repo_data
    }]


if __name__ == '__main__':
    import requests
    from bs4 import BeautifulSoup
    username = input("Enter github username: ")
    print_github_profile_data_from_url(username)
else:
    # Run module directly from a n8n Code Node
    log_debug('Importing micropip')
    import micropip
    log_debug('Installing dependencies: beautifulsoup4, requests')
    micropip.install('beautifulsoup4')
    from bs4 import BeautifulSoup
    items = _input.all()
    profile_content = items[0].get("json", {}).get("profile_data")
    repos_content = items[0].get("json", {}).get("repos_data")
    domain = items[0].get("json", {}).get("domain")
    log_debug(
        "Input data from previous node:"
        f"\n | domain: {domain}"
        f"\n | profile_content: {profile_content}"
        f"\n | repos_content: {repos_content}"
    )
    return get_github_profile_data_from_html(
        profile_content, repos_content, domain, True)
