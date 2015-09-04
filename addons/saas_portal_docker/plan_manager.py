from openerp import models, api


class SaasPortalPlanManager(models.TransientModel):
    _name = 'saas_portal.plan_manager'

    @api.model
    def create_template_databases(self):
        plan = self.env['saas_portal.plan'].search([('name', '=', 'Available quantity of products in POS')], limit=1)
        return plan.create_template()
