from odoo.tests.common import HttpCase, tagged

@tagged("post_install","-at_install")
class TestMediBookApi(HttpCase):
    def test_login_route_exists(self):
        response=self.url_open("/auth/login",method="POST",data=b'{"email":"","password":""}',headers={"Content-Type":"application/json"})
        self.assertEqual(response.status_code,400)
